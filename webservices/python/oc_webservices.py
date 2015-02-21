__author__ = 'Lstevens'

# stdlib modules
from xml.etree import ElementTree as et
import hashlib
import re
import logging

# pypi modules
import requests
import xmltodict

logging.basicConfig(
        filename='webservices.log',
        format='%(asctime)s | %(levelname)s | %(name)s | %(funcName)s | Line:%(lineno)d | %(message)s')


class OpenClinicaWebService(object):
    """
    Provide methods to call OpenClinica webservices and return the results.

    Implemented with etree, requests and xmltodict.
    Needs etree because xmltodict.unparse() doesn't insert required namespaces.
    All methods return an OrderedDict, or None if there was an error.
    """
    ns_se = 'http://schemas.xmlsoap.org/soap/envelope/'
    ns_we = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'
    ns_oc_odm = 'http://www.cdisc.org/ns/odm/v1.3'
    ns_oc = 'http://www.openclinica.org/ns/odm_ext_v130/v3.1'
    ns_ocrules = 'http://www.openclinica.org/ns/rules/v3.1'
    ns_beans = 'http://openclinica.org/ws/beans'
    ns_study = 'http://openclinica.org/ws/study/v1'
    ns_subject = 'http://openclinica.org/ws/studySubject/v1'
    ns_event = 'http://openclinica.org/ws/event/v1'
    ns_data = 'http://openclinica.org/ws/data/v1'

    def __init__(self, ocws_url, username, password, ocws_ca=True):
        """
        Create a soap envelope with a completed security header and empty body.

        Performs the common tasks in preparing a soap envelope for a request.
        The generated envelope has an empty body element that must be filled in.
        A str is returned so that it can be copied as there isn't an et.copy().

        Required params:
        :param ocws_url: location of OpenClinica webservices instance
        :type ocws_url: url.
        :param username: username of OpenClinica account to authenticate with.
        :type username: str.
        :param password: password of OpenClinica account to authenticate with.
        :type password: str.

        Optional params:
        :param ocws_ca: default of True means the requests copy of the 'certifi'
            CA bundle is used to verify the OpenClinica certificate. False means
            the certificate will not be verified, which results in warnings for
            each unverified request. Alternatively, specify the path to a pem
            file with the root (and intermediate) certificates from the
            certificate authority that issued the OpenClinica certificate.
        :type ocws_ca: bool, or directory path.

        :returns: str with the SOAP envelope.
        """
        namespaced_classname = '.'.join([__name__, self.__class__.__name__])
        self.log_ocws = logging.getLogger(namespaced_classname)
        self.log_ocws.setLevel(logging.INFO)
        envelope = et.Element(et.QName(self.ns_se, 'Envelope'))
        header = et.Element(et.QName(self.ns_se, 'Header'))
        body = et.Element(et.QName(self.ns_se, 'Body'))
        security_attrib = {'mustUnderstand': 'True'}
        security = et.Element(et.QName(self.ns_we, 'Security'), security_attrib)
        user_token = et.Element(et.QName(self.ns_we, 'UsernameToken'))
        user_name = et.Element(et.QName(self.ns_we, 'Username'))
        pass_word = et.Element(et.QName(self.ns_we, 'Password'))
        envelope.append(header)
        envelope.append(body)
        header.append(security)
        security.append(user_token)
        user_token.append(user_name)
        user_token.append(pass_word)
        user_name.text = username
        pass_word.text = hashlib.sha1(password.encode('utf-8')).hexdigest()
        self.envelope = et.tostring(envelope)
        if ocws_url[-1] == '/':
            self.ocws_url = '{0}ws/'.format(ocws_url)
        else:
            self.ocws_url = '{0}/ws/'.format(ocws_url)
        self.ocws_ca_bundle = ocws_ca

    def request(self, url, envelope, method_name, method_ns):
        """
        Send the SOAP envelope to the url and return the response body if any.

        For a successful call, the returned value is an OrderedDict which is
        the contents of the first child element of the SOAP response envelope.
        The namespaces are removed as they are just noise in an OrderedDict.
        An INFO log is written for successful calls.

        In this context, "success" means the call worked. The content of the
        response may still be a "result: Fail", e.g. if the call parameters
        are wrong - like a study_identifier that doesn't exist.

        For an unsuccessful call, the returned value is None.
        An ERROR log is written for unsuccessful calls.

        The handled unsuccessful call scenarios are:
            - Connection Error: e.g. bad URL, not listening, cert verify failed.
            - Empty response: e.g. the response content was not greater than 0.
            - No SOAP envelope: e.g. response content had no SOAP envelope.
            - SOAP Fault: e.g. response was a fault, e.g. authentication failed.

        The workflow in words:
        - Send the request.
        - If there is a connection error:
            - Log error and return None.
        - If there is a SSL certificate verification error:
            - Log error and return None.
        - If there is response content longer than zero:
            - Search for a soap envelope.
            - If there is a soap envelope:
                - Convert it into an OrderedDict with no namespaces.
                - If the response is a fault:
                    - Log error and return None.
                - Else:
                    - Log info and return content of the body first child.
            - Else:
                - Log error and return None.
        - Else:
            - Log error and return None.

        Each request should result in one log line.

        :param url: The url to send the request to.
        :type url: str
        :param envelope: The SOAP envelope xml to send as the request.
        :type url: str
        :param method_name: The method name being sent in the envelope.
        :type method_name: str
        :param method_ns: The namespace uri that the method name belongs to.
        :type method_ns: str
        :returns: contents of the method response in an OrderedDict, or None.
        """
        headers = {'content-type': 'text/xml; charset=UTF-8'}
        try:
            response = requests.post(
                url, data=envelope, headers=headers, verify=self.ocws_ca_bundle
            )
        except requests.exceptions.ConnectionError as pe:
            self.log_ocws.error(
                ' | '.join([method_name, 'Connection Error', url, str(pe),
                            str(self.ocws_ca_bundle)]))
            return None

        if len(response.content) > 0:
            soap_search = re.compile(
                '(<(?P<ns>.*?):Envelope.*</(?P=ns):Envelope>)', re.DOTALL)
            soap_matches = soap_search.search(response.content.decode())
            if soap_matches:
                content = soap_matches.group(0).encode('utf-8')
                ns_resp = {self.ns_se: None, method_ns: None,
                           self.ns_beans: None}
                resp_env = xmltodict.parse(
                    content, process_namespaces=True, namespaces=ns_resp)
                resp_body = resp_env['Envelope']['Body']
                resp_type = [i for i in iter(resp_body)][0]
                if resp_type == 'Fault':
                    fault_string = resp_body[resp_type]['faultstring']['#text']
                    self.log_ocws.error(
                        ' | '.join([method_name, 'Fault response', url,
                                    str(response.status_code), fault_string]))
                    return None
                else:
                    self.log_ocws.info(
                        ' | '.join([method_name, 'Success', resp_type, url,
                                    str(response.status_code)]))
                    return resp_body[resp_type]
            else:
                self.log_ocws.error(
                    ' | '.join([method_name, 'No SOAP envelope in response',
                                url, str(response.status_code)]))
                return None
        else:
            self.log_ocws.error(
                ' | '.join([method_name, 'Empty response ', url,
                            str(response.status_code)]))
            return None

    def study_list_all(self):
        """
        Return result of query for details on all studies in the instance.

        :returns: contents of the method response in an OrderedDict, or None.
        """
        envelope_copy = et.fromstring(self.envelope)
        body = [i for i in envelope_copy.iterfind(
            './/se:Body', {'se': self.ns_se})][0]

        method_name = 'listAllRequest'
        list_all = et.Element(et.QName(self.ns_study, method_name))
        body.append(list_all)

        envelope = et.tostring(envelope_copy)
        response = self.request(
            self.ocws_url, envelope, method_name, self.ns_study)
        return response

    def study_get_metadata(self, study_identifier):
        """
        Return result of query for metadata for a study.

        Attempts to parse the ODM raw xml into an OrderedDict as well.

        Required params:
        :param study_identifier: unique identifier (not OID) of study.
        :type study_identifier: str.

        :returns: contents of the method response in an OrderedDict, or None.
        """
        envelope_copy = et.fromstring(self.envelope)
        body = [i for i in envelope_copy.iterfind(
            './/se:Body', {'se': self.ns_se})][0]

        method_name = 'getMetadataRequest'
        get_metadata = et.Element(et.QName(self.ns_study, method_name))
        body.append(get_metadata)

        study_metadata = et.Element(et.QName(self.ns_study, 'studyMetadata'))
        get_metadata.append(study_metadata)

        study_ident = et.Element(et.QName(self.ns_beans, 'identifier'))
        study_ident.text = study_identifier
        study_metadata.append(study_ident)

        envelope = et.tostring(envelope_copy)
        response = self.request(
            self.ocws_url, envelope, method_name, self.ns_study)
        try:
            ns_odm = {self.ns_oc_odm: None, self.ns_oc: None,
                      self.ns_ocrules: None}
            response['odm'] = xmltodict.parse(
                response['odm'], process_namespaces=True, namespaces=ns_odm)
        except TypeError:
            # Request failed and the response was None (can't subscript None)
            pass
        except KeyError:
            # Call failed and 'odm' is not in response (bad study_identifier)
            pass
        return response

    def study_subject_list_all_by_study(
            self, study_identifier, site_identifier=None,
            with_subject_oids=False):
        """
        Return result of query for details of subjects at a study (and site).

        Required params:
        :param study_identifier: unique identifier (not OID) of study.
        :type study_identifier: str.

        Optional params:
        :param site_identifier: unique identifier (not OID) of site.
        :type site_identifier: str.

        :returns: contents of the method response in an OrderedDict, or None.
        """
        envelope_copy = et.fromstring(self.envelope)
        body = [i for i in envelope_copy.iterfind(
            './/se:Body', {'se': self.ns_se})][0]

        method_name = 'listAllByStudyRequest'
        list_all_by_study = et.Element(et.QName(self.ns_subject, method_name))
        body.append(list_all_by_study)

        study_ref = et.Element(et.QName(self.ns_beans, 'studyRef'))
        list_all_by_study.append(study_ref)

        study_ident = et.Element(et.QName(self.ns_beans, 'identifier'))
        study_ident.text = study_identifier
        study_ref.append(study_ident)

        if site_identifier is not None:
            site_ref = et.Element(et.QName(self.ns_beans, 'siteRef'))
            site_ident = et.Element(et.QName(self.ns_beans, 'identifier'))
            site_ident.text = site_identifier
            site_ref.append(site_ident)
            study_ref.append(site_ref)

        envelope = et.tostring(envelope_copy)
        response = self.request(
            self.ocws_url, envelope, method_name, self.ns_subject)

        if response is not None:
            try:
                response_success = response['result']
            except KeyError:
                response_success = 'Fail'

            if with_subject_oids and response_success == 'Success':
                for subject in response['studySubjects']['studySubject']:
                    is_subject = self.study_subject_is_subject(
                        study_identifier, subject['label'], site_identifier)
                    if is_subject is not None:
                        subject['subjectOID'] = is_subject['subjectOID']
                    else:
                        subject['subjectOID'] = 'not found'

        return response

    def study_subject_create(
            self, study_identifier, enrollment_date, study_subject_id=None,
            secondary_label=None, person_id=None, gender=None,
            date_or_year_of_birth=None, site_identifier=None
    ):
        """
        Return result of request to create a study subject.

        Some optional params may be required for successful creation, depending
        on the study parameter settings of the target study.

        Required params:
        :param study_identifier: unique identifier (not OID) of study.
        :type study_identifier: str.
        :param enrollment_date: ISO-8601 format date (2015-01-01) for enrollment.
        :type enrollment_date: str.

        Optional params:
        :param study_subject_id: study subject ID (not OID) to create.
        :type study_subject_id: str.
        :param secondary_label: study subject secondary label.
        :type secondary_label: str.
        :param person_id: subject person ID.
        :type person_id: str.
        :param gender: subject gender 'm' or 'f'.
        :type gender: str.
        :param date_or_year_of_birth: ISO-8601 format date for subject date of
            birth. Either full date (1990-10-10) or year only (1990).
        :type date_or_year_of_birth: str.
        :param site_identifier: unique identifier (not OID) of site.
        :type site_identifier: str.

        :returns: contents of the method response in an OrderedDict, or None.
        """
        envelope_copy = et.fromstring(self.envelope)
        body = [i for i in envelope_copy.iterfind(
            './/se:Body', {'se': self.ns_se})][0]

        method_name = 'createRequest'
        create_subject = et.Element(et.QName(self.ns_subject, method_name))
        body.append(create_subject)

        study_subject = et.Element(et.QName(self.ns_subject, 'studySubject'))
        create_subject.append(study_subject)

        subject_enrol = et.Element(et.QName(self.ns_beans, 'enrollmentDate'))
        subject_enrol.text = enrollment_date
        study_subject.append(subject_enrol)

        subject = et.Element(et.QName(self.ns_beans, 'subject'))
        study_subject.append(subject)

        study_ref = et.Element(et.QName(self.ns_beans, 'studyRef'))
        study_subject.append(study_ref)

        study_ident = et.Element(et.QName(self.ns_beans, 'identifier'))
        study_ident.text = study_identifier
        study_ref.append(study_ident)

        if study_subject_id is not None:
            subject_label = et.Element(et.QName(self.ns_beans, 'label'))
            subject_label.text = study_subject_id
            study_subject.append(subject_label)

        if secondary_label is not None:
            subject_secondary = et.Element(et.QName(
                self.ns_beans, 'secondaryLabel'))
            subject_secondary.text = secondary_label
            study_subject.append(subject_secondary)

        if person_id is not None:
            subject_person_id = et.Element(et.QName(
                self.ns_beans, 'uniqueIdentifier'))
            subject_person_id.text = person_id
            subject.append(subject_person_id)

        if gender is not None:
            subject_gender = et.Element(et.QName(self.ns_beans, 'gender'))
            subject_gender.text = gender
            subject.append(subject_gender)

        if date_or_year_of_birth is not None:
            if len(date_or_year_of_birth) > 4:
                subject_dob = et.Element(et.QName(
                    self.ns_beans, 'dateOfBirth'))
                subject_dob.text = date_or_year_of_birth
                subject.append(subject_dob)
            if len(date_or_year_of_birth) == 4:
                subject_yob = et.Element(et.QName(
                    self.ns_beans, 'yearOfBirth'))
                subject_yob.text = date_or_year_of_birth
                subject.append(subject_yob)

        if site_identifier is not None:
            site_ref = et.Element(et.QName(self.ns_beans, 'siteRef'))
            site_ident = et.Element(et.QName(self.ns_beans, 'identifier'))
            site_ident.text = site_identifier
            site_ref.append(site_ident)
            study_ref.append(site_ref)

        envelope = et.tostring(envelope_copy)
        response = self.request(
            self.ocws_url, envelope, method_name, self.ns_subject)
        return response

    def study_subject_is_subject(
            self, study_identifier, study_subject_id, site_identifier=None
    ):
        """
        Return result of request to create a study subject.

        Required params:
        :param study_identifier: unique identifier (not OID) of study.
        :type study_identifier: str.
        :param study_subject_id: study subject ID (not OID) to check.
        :type study_subject_id: str.

        Optional params:
        :param site_identifier: unique identifier (not OID) of site.
        :type site_identifier: str.

        :returns: contents of the method response in an OrderedDict, or None.
        """
        envelope_copy = et.fromstring(self.envelope)
        body = [i for i in envelope_copy.iterfind(
            './/se:Body', {'se': self.ns_se})][0]

        method_name = 'isStudySubjectRequest'
        is_subject = et.Element(et.QName(self.ns_subject, method_name))
        body.append(is_subject)

        study_subject = et.Element(et.QName(self.ns_subject, 'studySubject'))
        is_subject.append(study_subject)

        subject_label = et.Element(et.QName(self.ns_beans, 'label'))
        subject_label.text = study_subject_id
        study_subject.append(subject_label)

        study_ref = et.Element(et.QName(self.ns_beans, 'studyRef'))
        study_subject.append(study_ref)

        study_ident = et.Element(et.QName(self.ns_beans, 'identifier'))
        study_ident.text = study_identifier
        study_ref.append(study_ident)

        if site_identifier is not None:
            site_ref = et.Element(et.QName(self.ns_beans, 'siteRef'))
            site_ident = et.Element(et.QName(self.ns_beans, 'identifier'))
            site_ident.text = site_identifier
            site_ref.append(site_ident)
            study_ref.append(site_ref)

        envelope = et.tostring(envelope_copy)
        response = self.request(
            self.ocws_url, envelope, method_name, self.ns_subject)
        return response

    def event_schedule(
        self, study_identifier, study_subject_id, event_definition_oid,
        event_location, event_start_date, site_identifier=None,
        event_start_time=None, event_end_date=None, event_end_time=None
    ):
        """
        Return result of request to schedule an event for a subject.

        Required params:
        :param study_identifier: unique identifier (not OID) of study.
        :type study_identifier: str.
        :param study_subject_id: study subject ID (not OID) to schedule event for.
        :type study_subject_id: str.
        :param event_definition_oid: event definition OID of event to schedule.
        :type event_definition_oid: str.
        :param event_location: non-blank location, required despite study settings.
        :type event_location: str.
        :param event_start_date: ISO-8601 format date (2015-01-01) for event start.
        :type event_start_date: str.

        Optional params:
        :param site_identifier: unique identifier (not OID) of site.
        :type site_identifier: str.
        :param event_start_time: ISO-8601 format time (13:51) for event start.
        :type event_start_time: str.
        :param event_end_date: ISO-8601 format date (2015-01-01) for event end.
        :type event_end_date: str.
        :param event_end_time: ISO-8601 format time (13:51) for event end.
        :type event_end_time: str.

        :returns: contents of the method response in an OrderedDict, or None.
        """
        envelope_copy = et.fromstring(self.envelope)
        body = [i for i in envelope_copy.iterfind(
            './/se:Body', {'se': self.ns_se})][0]

        method_name = 'scheduleRequest'
        schedule_event = et.Element(et.QName(self.ns_event, method_name))
        body.append(schedule_event)

        event = et.Element(et.QName(self.ns_event, 'event'))
        schedule_event.append(event)

        study_subject = et.Element(et.QName(self.ns_beans, 'studySubjectRef'))
        event.append(study_subject)

        subject_label = et.Element(et.QName(self.ns_beans, 'label'))
        subject_label.text = study_subject_id
        study_subject.append(subject_label)

        study_ref = et.Element(et.QName(self.ns_beans, 'studyRef'))
        event.append(study_ref)

        study_ident = et.Element(et.QName(self.ns_beans, 'identifier'))
        study_ident.text = study_identifier
        study_ref.append(study_ident)

        event_oid = et.Element(et.QName(self.ns_beans, 'eventDefinitionOID'))
        event_oid.text = event_definition_oid
        event.append(event_oid)

        event_loc = et.Element(et.QName(self.ns_beans, 'location'))
        event_loc.text = event_location
        event.append(event_loc)

        event_start_d = et.Element(et.QName(self.ns_beans, 'startDate'))
        event_start_d.text = event_start_date
        event.append(event_start_d)

        if event_start_time is not None:
            event_start_t = et.Element(et.QName(self.ns_beans, 'startTime'))
            event_start_t.text = event_start_time
            event.append(event_start_t)

        if event_end_date is not None:
            event_end_d = et.Element(et.QName(self.ns_beans, 'endDate'))
            event_end_d.text = event_end_date
            event.append(event_end_d)

        if event_end_time is not None:
            event_end_t = et.Element(et.QName(self.ns_beans, 'endTime'))
            event_end_t.text = event_end_time
            event.append(event_end_t)

        if site_identifier is not None:
            site_ref = et.Element(et.QName(self.ns_beans, 'siteRef'))
            site_ident = et.Element(et.QName(self.ns_beans, 'identifier'))
            site_ident.text = site_identifier
            site_ref.append(site_ident)
            study_ref.append(site_ref)

        envelope = et.tostring(envelope_copy)
        response = self.request(
            self.ocws_url, envelope, method_name, self.ns_event)
        return response

    def data_import(self, odm):
        """
        Return result of request to import data to an instance.

        Required params:
        :param odm: odm xml data for import, must be utf-8 encoded and unescaped.
        :type odm: str.

        :returns: contents of the method response in an OrderedDict, or None.
        """
        envelope_copy = et.fromstring(self.envelope)
        body = [i for i in envelope_copy.iterfind(
            './/se:Body', {'se': self.ns_se})][0]

        method_name = 'importRequest'
        import_request = et.Element(et.QName(self.ns_data, method_name))
        body.append(import_request)

        odm_node = et.Element('odm')
        odm_node.append(et.fromstring(odm))
        import_request.append(odm_node)

        envelope = et.tostring(envelope_copy)
        response = self.request(
            self.ocws_url, envelope, method_name, self.ns_data)
        return response