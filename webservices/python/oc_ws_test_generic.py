__author__ = 'Lstevens'

# stdlib
import unittest
import collections
import datetime
import uuid

# local
import oc_webservices

"""
These objects are used by oc_ws_test to create common tests and set common
value used by the oc_ws_test tests. The GenericCallFailures TestCase will not
run on its own, it requires that the inheriting TestCase sets the parameters
"function_to_test_name" and "function_to_test_kwargs".
"""


class TestGlobals(object):

    test_url = "https://localhost:8443/OpenClinica3141-ws/"
    test_username = 'lstevens'
    test_password = 'aGoodPassword'
    test_study_identifier = 'VHCRP1302'
    test_site_identifier = None
    bad_cert_path = 'badcert.crt'

    test_ocws_instance = oc_webservices.OpenClinicaWebService(
        test_url, test_username, test_password, False)
    study_metadata = None
    study_oid = None
    subject_create_params = None
    event_schedule_params = None
    first_event_oid = None
    data_import_first_objects = None

    today_datetime = datetime.datetime.today()
    today_iso8601 = today_datetime.strftime('%Y-%m-%d')

    @staticmethod
    def list_of_ordered_dict_or_copy_list(lookup):
        return_list = list()
        if isinstance(lookup, collections.OrderedDict):
            return_list.append(lookup)
        elif isinstance(lookup, list):
            return_list = lookup
        return return_list

    def get_metadata(self):
        meta_params = {'study_identifier': self.test_study_identifier}
        metadata = self.test_ocws_instance.study_get_metadata(**meta_params)
        study_lookup = metadata['odm']['ODM']['Study']
        studies = self.list_of_ordered_dict_or_copy_list(study_lookup)
        for study in studies:
            protocol_name = study['GlobalVariables']['ProtocolName']
            if protocol_name == self.test_study_identifier:
                self.study_metadata = study
                self.study_oid = study['@OID']

    def set_subject_create_params(self):
        if self.study_metadata is None:
            self.get_metadata()
        meta_v = self.study_metadata['MetaDataVersion']
        param_c = meta_v['StudyDetails']['StudyParameterConfiguration']
        study_config = param_c['StudyParameterListRef']
        configs = dict()
        for config in study_config:
            config_param = config.get('@StudyParameterListID')
            if config_param is not None:
                configs[config_param] = config.get('@Value')
        study_subject_id = None
        subject_gender = 'm'  # OC bug (3.1.4.1): gender always required
        subject_person_id = None
        subject_dob = None
        enrollment_date = self.today_iso8601
        if configs['SPL_subjectIdGeneration'] == 'manual':
            study_subject_id = 'will be set'
        if configs['SPL_genderRequired'] == 'true':
            subject_gender = 'm'
        if configs['SPL_subjectPersonIdRequired'] == 'required':
            subject_person_id = 'will be set'
        if configs['SPL_collectDob'] == '1':  # Full date
            subject_dob = self.today_iso8601
        elif configs['SPL_collectDob'] == '2':  # Year only
            subject_dob = self.today_datetime.strftime('%Y')
        self.subject_create_params = {
            'study_identifier': self.test_study_identifier,
            'enrollment_date': enrollment_date,
            'study_subject_id': study_subject_id,
            'secondary_label': 'ocws test subject',
            'person_id': subject_person_id,
            'gender': subject_gender,
            'date_or_year_of_birth': subject_dob,
            'site_identifier': self.test_site_identifier
        }

    @staticmethod
    def set_new_subject_id_params_if_needed(params):
        params = params.copy()
        subject_uuid = 'test_{0}'.format(uuid.uuid4().hex[:25])
        if params['study_subject_id'] is not None:
            params['study_subject_id'] = subject_uuid
        if params['person_id'] is not None:
            params['person_id'] = subject_uuid
        return params

    def get_new_subject_label(self):
        if self.subject_create_params is None:
            self.set_subject_create_params()
        subject_params = self.set_new_subject_id_params_if_needed(
            self.subject_create_params)
        subject = self.test_ocws_instance.study_subject_create(**subject_params)
        return subject['label']

    def set_event_schedule_params(self):
        if self.study_metadata is None:
            self.get_metadata()
        event_lookup = self.study_metadata['MetaDataVersion']['StudyEventDef']
        event_defs = self.list_of_ordered_dict_or_copy_list(event_lookup)
        self.first_event_oid = event_defs[0]['@OID']
        self.event_schedule_params = {
            'study_identifier': self.test_study_identifier,
            'study_subject_id': None,
            'event_definition_oid': self.first_event_oid,
            'event_location': 'ocws test event',
            'event_start_date': self.today_iso8601,
            'event_start_time': None,
            'event_end_date': None,
            'event_end_time': None,
            'site_identifier': self.test_site_identifier
        }

    def get_new_subject_event(self, event_definition_oid=None):
        if self.event_schedule_params is None:
            self.set_event_schedule_params()
        subject_label = self.get_new_subject_label()
        event_params = self.event_schedule_params.copy()
        event_params['study_subject_id'] = subject_label
        if event_definition_oid is not None:
            event_params['event_definition_oid'] = event_definition_oid
        event = self.test_ocws_instance.event_schedule(**event_params)
        return event

    def set_study_metadata_event_defs_tree(self):
        if self.event_schedule_params is None:
            self.set_event_schedule_params()

        event_defs = self.list_of_ordered_dict_or_copy_list(
            self.study_metadata['MetaDataVersion']['StudyEventDef'])
        form_defs = self.list_of_ordered_dict_or_copy_list(
            self.study_metadata['MetaDataVersion']['FormDef'])
        item_group_defs = self.list_of_ordered_dict_or_copy_list(
            self.study_metadata['MetaDataVersion']['ItemGroupDef'])
        item_defs = self.list_of_ordered_dict_or_copy_list(
            self.study_metadata['MetaDataVersion']['ItemDef'])
        code_list_defs = self.list_of_ordered_dict_or_copy_list(
            self.study_metadata['MetaDataVersion']['CodeList'])

        for event_def in event_defs:
            form_refs = event_def.get('FormRef')
            form_def_list = list()
            if form_refs is not None:
                form_refs = self.list_of_ordered_dict_or_copy_list(form_refs)
                for form_ref in form_refs:
                    for form_def in form_defs:
                        if form_ref['@FormOID'] == form_def['@OID']:
                            form_def_list.append(form_def)
            event_def['FormDefs'] = form_def_list
            for form_def in event_def['FormDefs']:
                item_group_ref = form_def.get('ItemGroupRef')
                item_group_def_list = list()
                if item_group_ref is not None:
                    item_group_refs = self.list_of_ordered_dict_or_copy_list(item_group_ref)
                    for item_group_ref in item_group_refs:
                        for item_group_def in item_group_defs:
                            if item_group_ref['@ItemGroupOID'] == item_group_def['@OID']:
                                item_group_def_list.append(item_group_def)
                form_def['ItemGroupDefs'] = item_group_def_list
                for item_group_def in form_def['ItemGroupDefs']:
                    item_ref = item_group_def.get('ItemRef')
                    item_def_list = list()
                    if item_ref is not None:
                        item_refs = self.list_of_ordered_dict_or_copy_list(item_ref)
                        for item_ref in item_refs:
                            for item_def in item_defs:
                                if item_ref['@ItemOID'] == item_def['@OID']:
                                    item_def_list.append(item_def)
                    item_group_def['ItemDefs'] = item_def_list
                    for item_def in item_group_def['ItemDefs']:
                        code_list_ref = item_def.get('CodeListRef')
                        code_list_def_list = list()
                        if code_list_ref is not None:
                            code_list_refs = self.list_of_ordered_dict_or_copy_list(code_list_ref)
                            for code_list_ref in code_list_refs:
                                for code_list_def in code_list_defs:
                                    if code_list_ref['@CodeListOID'] == code_list_def['@OID']:
                                        code_list_def_list.append(code_list_def)
                        item_def['CodeListDef'] = code_list_def_list

        self.study_metadata['EventDefs'] = event_defs

    def set_data_import_first_objects(self):
        if self.study_metadata.get('EventDefs') is None:
            self.set_study_metadata_event_defs_tree()

        event = dict()
        for event_def in self.study_metadata['EventDefs']:
            if event_def['@OID'] == self.first_event_oid:
                event = event_def
        form_def = event['FormDefs'][0]
        item_group_def = form_def['ItemGroupDefs'][0]
        item_def = item_group_def['ItemDefs'][0]
        code_list_def = item_def.get('CodeListDef')
        if len(code_list_def) > 0:
            item_value = code_list_def[0]['CodeListItem'][0]['@CodedValue']
        else:
            if item_def['@DataType'] in ['text', 'integer', 'float']:
                item_value = '1'
            elif item_def['@DataType'] == 'date':
                item_value = self.today_iso8601
            else:  # pdate, file
                item_value = ''

        self.data_import_first_objects = dict()
        self.data_import_first_objects['event'] = self.first_event_oid
        self.data_import_first_objects['form'] = form_def['@OID']
        self.data_import_first_objects['item_group'] = item_group_def['@OID']
        self.data_import_first_objects['item'] = item_def['@OID']
        self.data_import_first_objects['item_value'] = item_value


class GenericCallFailures(unittest.TestCase, TestGlobals):

    def __init__(self, methodName='runTest', function_to_test_name=None,
                 function_to_test_kwargs=None):
        super(GenericCallFailures, self).__init__(methodName)
        self.function_to_test_name = function_to_test_name
        self.function_to_test_kwargs = function_to_test_kwargs
        if self.test_url[-1] == '/':
            self.bad_url_path = '{0}resource/probably/wont/exist'.format(
                self.test_url)
        else:
            self.bad_url_path = '{0}/resource/probably/wont/exist'.format(
                self.test_url)
        self.bad_url_location = 'http://localhost:12345/probably/wont/be/listening'
        self.bad_username = self.test_username[:-2]
        self.bad_password = self.test_password[:-2]
        self.too_many_logs_msg = 'More than one log line written for a single call'

    def generic_call_actions(self, ocws_url=None, username=None,
                             password=None, ocws_ca=None):
        if ocws_url is None:
            ocws_url = self.test_url
        if username is None:
            username = self.test_username
        if password is None:
            password = self.test_password
        if ocws_ca is None:
            ocws_ca = False
        ocws_instance = oc_webservices.OpenClinicaWebService(
            ocws_url, username, password, ocws_ca)
        log_ocws = 'oc_webservices.OpenClinicaWebService'
        func_name = str(self.function_to_test_name)
        func_args = self.function_to_test_kwargs
        with self.assertLogs(log_ocws, level='DEBUG') as logs:
            func_bind = getattr(ocws_instance, func_name)
            if func_args is None:
                result = func_bind()
            else:
                result = func_bind(**func_args)
        return logs.output, result

    def test_wrong_url_path_no_soapenv_from_log(self):
        log_match = 'No SOAP envelope in response'
        logs, result = self.generic_call_actions(ocws_url=self.bad_url_path)
        if len(logs) > 1:
            self.fail(self.too_many_logs_msg)
        else:
            self.assertRegex(logs[0], log_match)

    def test_wrong_url_path_returns_none(self):
        logs, result = self.generic_call_actions(ocws_url=self.bad_url_path)
        self.assertIsNone(result)

    def test_wrong_url_location_connection_error_from_log(self):
        log_match = 'Connection Error'
        logs, result = self.generic_call_actions(ocws_url=self.bad_url_location)
        if len(logs) > 1:
            self.fail(self.too_many_logs_msg)
        else:
            self.assertRegex(logs[0], log_match)

    def test_wrong_url_location_returns_none(self):
        logs, result = self.generic_call_actions(ocws_url=self.bad_url_location)
        self.assertIsNone(result)

    def test_wrong_cert_connection_error_from_log(self):
        log_match = 'Connection Error'
        logs, result = self.generic_call_actions(ocws_ca=self.bad_cert_path)
        if len(logs) > 1:
            self.fail(self.too_many_logs_msg)
        else:
            self.assertRegex(logs[0], log_match)

    def test_wrong_cert_returns_none(self):
        logs, result = self.generic_call_actions(ocws_ca=self.bad_cert_path)
        self.assertIsNone(result)

    def test_wrong_username_auth_failure_from_log(self):
        log_match = 'Authentication of Username Password Token Failed'
        logs, result = self.generic_call_actions(username=self.bad_username)
        if len(logs) > 1:
            self.fail(self.too_many_logs_msg)
        else:
            self.assertRegex(logs[0], log_match)

    def test_wrong_username_returns_none(self):
        logs, result = self.generic_call_actions(username=self.bad_username)
        self.assertIsNone(result)

    def test_wrong_password_auth_failure_from_log(self):
        log_match = 'Authentication of Username Password Token Failed'
        logs, result = self.generic_call_actions(password=self.bad_password)
        if len(logs) > 1:
            self.fail(self.too_many_logs_msg)
        else:
            self.assertRegex(logs[0], log_match)

    def test_wrong_password_returns_none(self):
        logs, result = self.generic_call_actions(password=self.bad_password)
        self.assertIsNone(result)

    def test_exec_good_call_returns_ordered_dict(self):
        logs, result = self.generic_call_actions()
        self.assertIsInstance(result, collections.OrderedDict)

    def test_exec_good_params_result_success(self):
        logs, result = self.generic_call_actions()
        self.assertEqual('Success', result['result'])