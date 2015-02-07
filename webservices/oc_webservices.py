from suds.client import Client, WebFault
from suds.plugin import MessagePlugin
from suds.wsse import Security, UsernameToken
import re
import hashlib
import logging
from xml.etree import ElementTree as et


class TrimMultiPartReply(MessagePlugin):
    def received(self, context):
        """
        Trim response to prevent parse failure on methods with multipart text
        """

        soap_search = re.compile('(<SOAP-ENV:Envelope.*</SOAP-ENV:Envelope>)')
        soap_matches = soap_search.search(context.reply.decode())

        if soap_matches:
            context.reply = soap_matches.group(0).encode('utf-8')
        else:
            print('No SOAP envelope found in response')


def ocws_client_create(wsdl_url, username, password, plugins=None):
    """
    Return a SOAP client instance with authentication header set.

    Includes a plugin to help parsing, and a security header for authentication.
    The OpenClinica account must have permission to use SOAP webservices.

    The request elements need to be created before the instance can be used.
    In general the steps involved are as follows, this function does step 1:
    1. create client instance for request.
    2. add request elements.
    3. call webservice method with constructed request object.
    4. return result.

    Required params:
    :param wsdl_url: url of the wsdl that the SOAP client will use
    :type wsdl_url: str.
    :param username: username of OpenClinica account to authenticate with
    :type username: str.
    :param password: password of OpenClinica account to authenticate with
    :type password: str.

    Optional params:
    :param plugins: list of suds plugins to use with the client instance
    :type plugins: list.

    :return: suds.Client instance with security header
    """
    ocws_client = Client(wsdl_url, plugins=plugins)
    security = Security()
    token = UsernameToken(
        username,
        hashlib.sha1(password.encode('utf-8')).hexdigest()
    )
    security.tokens.append(token)
    ocws_client.set_options(wsse=security)
    ocws_client.add_prefix('ocbeans', 'http://openclinica.org/ws/beans')

    return ocws_client


def study_list_all(ocws_url, username, password):
    """
    Return result of query for details on all studies.

    The object returned is a list/dict equivalent of the xml response.

    username and password are passed through to ocws_client_create.
    See ocws_client_create for these param descriptions.

    Required params:
    :param ocws_url: URL of OpenClinica webservices instance.
    :type ocws_url: str.

    :return: list/dict response from call to study.listAll().
    """
    wsdl_url = "{0}{1}".format(ocws_url, '/ws/study/v1/studyWsdl.wsdl')
    ocws_client = ocws_client_create(wsdl_url, username, password)

    print('Call Attempt : study.listAll() : Starting')
    resp = ocws_client.service.listAll()
    print('Call Attempt : study.listAll() : {0}'.format(resp.result))

    return resp


def study_subject_list_all_by_study(
        ocws_url, username, password, study_identifier, site_identifier=None):
    """
    Return result of query for details of subjects at a study and/or site.

    The object returned is a list/dict equivalent of the xml response.

    username and password are passed through to ocws_client_create.
    See ocws_client_create for these param descriptions.

    Required params:
    :param ocws_url: URL of OpenClinica webservices instance.
    :type ocws_url: str.
    :param study_identifier: unique identifier (not OID) of study.
    :type study_identifier: str.

    Optional params:
    :param site_identifier: unique identifier (not OID) of site.
    :type site_identifier: str.

    :returns: list/dict response from call to studySubject.listAllByStudy().
    """
    wsdl_url = "{0}{1}".format(ocws_url, '/ws/study/v1/studySubjectWsdl.wsdl')
    plugins = [TrimMultiPartReply()]
    ocws_client = ocws_client_create(wsdl_url, username, password, plugins)

    study = ocws_client.factory.create('ocbeans:studyRefType')
    study.identifier = study_identifier
    if site_identifier is not None:
        site = ocws_client.factory.create('ocbeans:siteRefType')
        site.identifier = site_identifier
        study.siteRef = site

    print('Call Attempt : studySubject.listAllByStudy() : Starting')
    resp = ocws_client.service.listAllByStudy(study)
    print('Call Attempt : studySubject.listAllByStudy() : {0}'.format(
        resp.result))

    return resp


def event_schedule(
        ocws_url, username, password, study_identifier, study_subject_id,
        event_definition_oid, event_location, event_start_date,
        site_identifier=None, event_start_time=None, event_end_date=None,
        event_end_time=None
):
    """
    Return result of request to schedule an event for a subject.

    The object returned is a list/dict equivalent of the xml response.

    username and password are passed through to ocws_client_create.
    See ocws_client_create for these param descriptions.

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

    :returns: list/dict response from call to event.schedule().
    """
    wsdl_url = "{0}{1}".format(ocws_url, '/ws/event/v1/eventWsdl.wsdl')
    ocws_client = ocws_client_create(wsdl_url, username, password)

    event = ocws_client.factory.create('ocbeans:eventType')

    study = ocws_client.factory.create('ocbeans:studyRefType')
    study.identifier = study_identifier
    event.studyRef = study

    study_subject = ocws_client.factory.create('ocbeans:studySubjectRefType')
    study_subject.label = study_subject_id
    event.studySubjectRef = study_subject

    event.eventDefinitionOID = event_definition_oid
    event.location = event_location
    event.startDate = event_start_date

    if site_identifier is not None:
        site = ocws_client.factory.create('ocbeans:siteRefType')
        site.identifier = site_identifier
        study.siteRef = site
    if event_start_time is not None:
        event.startTime = event_start_time
    if event_end_date is not None:
        event.endDate = event_end_date
    if event_end_time is not None:
        event.endTime = event_end_time

    print('Call Attempt : event.schedule() : Starting')
    resp = ocws_client.service.schedule(study)
    print('Call Attempt : event.schedule() : {0}'.format(resp.result))

    return resp


def study_get_metadata(
        ocws_url, username, password, study_identifier, site_identifier=None):
    """
    Return result of query for configurations details for a study and/or site.

    The object returned is an etree object with ODM xml contained in response.

    The ODM xml is the same as what can be downloaded from the UI.
    Example of syntax for navigating the etree object to find item OIDs:

    odm_ns = dict(odm='http://www.cdisc.org/ns/odm/v1.3')
    item_oids = [i.get('OID') for i in odm.iterfind('.//odm:ItemDef', odm_ns)]

    username and password are passed through to ocws_client_create.
    See ocws_client_create for these param descriptions.

    Required params:
    :param ocws_url: URL of OpenClinica webservices instance.
    :type ocws_url: str.
    :param study_identifier: unique identifier (not OID) of study.
    :type study_identifier: str.

    Optional params:
    :param site_identifier: unique identifier (not OID) of site.
    :type site_identifier: str.

    :returns: etree object with ODM xml response from call to study.getMetadata().
    """
    wsdl_url = "{0}{1}".format(ocws_url, '/ws/study/v1/studyWsdl.wsdl')
    ocws_client = ocws_client_create(wsdl_url, username, password)

    study = ocws_client.factory.create('ocbeans:studyRefType')
    study.identifier = study_identifier
    if site_identifier is not None:
        site = ocws_client.factory.create('ocbeans:siteRefType')
        site.identifier = site_identifier
        study.siteRef = site

    ocws_client.set_options(retxml=True)
    print('Call Attempt : study.getMetadata() : Starting')
    resp = ocws_client.service.getMetadata(study)
    resp_et = et.fromstring(resp.decode())
    resp_ns = dict(v1='http://openclinica.org/ws/study/v1')
    resp_result = [i for i in resp_et.iterfind('.//v1:result', resp_ns)][0].text
    print('Call Attempt : study.getMetadata() : {0}'.format(resp_result))
    odm = et.fromstring(
        [i for i in resp_et.iterfind('.//v1:odm', resp_ns)][0].text)

    return odm