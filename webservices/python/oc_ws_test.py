__author__ = 'Lstevens'

# stdlib
import unittest
import hashlib
import xml.etree.ElementTree as et

# local
import oc_ws_test_generic as owtg

# 3rd party
import xmltodict

# 83% test coverage


class TestOCWSInit(unittest.TestCase, owtg.TestGlobals):

    def setUp(self):
        self.envelope_etree = et.fromstring(self.test_ocws_instance.envelope)

    def test_envelope_converts_to_etree_element(self):
        envelope_etree = et.fromstring(self.test_ocws_instance.envelope)
        self.assertIsInstance(envelope_etree, et.Element)

    def test_envelope_contains_username(self):
        for node in self.envelope_etree.iter():
            if node.tag.endswith('Username'):
                self.assertEqual(self.test_username, node.text)

    def test_envelope_contains_password(self):
        pass_hash = hashlib.sha1(self.test_password.encode('utf-8')).hexdigest()
        for node in self.envelope_etree.iter():
            if node.tag.endswith('Password'):
                self.assertEqual(pass_hash, node.text)

    def test_ocws_instance_contains_valid_url(self):
        self.assertTrue(
            self.test_ocws_instance.ocws_url.startswith(self.test_url))


class TestStudyListAll(owtg.GenericCallFailures):

    def setUp(self):
        self.function_to_test_name = 'study_list_all'
        self.function_to_test_kwargs = None

    def test_good_params_site(self):
        logs, result = self.generic_call_actions()
        self.assertEqual('Success', result['result'])


class TestStudyGetMetadata(owtg.GenericCallFailures):

    def setUp(self):
        self.params = {
            'study_identifier': self.test_study_identifier
        }
        self.function_to_test_name = 'study_get_metadata'
        self.function_to_test_kwargs = self.params

    def test_wrong_params_result_fail(self):
        params = self.params.copy()
        params['study_identifier'] = 'no study called this'
        result = self.test_ocws_instance.study_get_metadata(**params)
        self.assertEqual('Fail', result['result'])

    def test_good_call_returns_correct_metadata(self):
        logs, result = self.generic_call_actions()
        result_studies = result['odm']['ODM']['Study']
        result_study_ids = [
            sid['GlobalVariables']['ProtocolName'] for sid in result_studies
        ]
        self.assertIn(self.test_study_identifier, result_study_ids)


class TestStudySubjectListAllByStudy(owtg.GenericCallFailures):

    def setUp(self):
        self.params = {
            'study_identifier': self.test_study_identifier,
            'site_identifier': None,
            'with_subject_oids': False
        }
        self.function_to_test_name = 'study_subject_list_all_by_study'
        self.function_to_test_kwargs = self.params

    def test_exec_wrong_params_result_fail(self):
        params = self.params.copy()
        params['study_identifier'] = 'no study called this'
        result = self.test_ocws_instance.study_subject_list_all_by_study(**params)
        self.assertEqual('Fail', result['result'])

    def test_exec_optional_params_subject_oids_true_success(self):
        params = self.params.copy()
        params['with_subject_oids'] = True
        result = self.test_ocws_instance.study_subject_list_all_by_study(**params)
        self.assertEqual('Success', result['result'])

    @unittest.skipIf(
        owtg.TestGlobals.test_site_identifier is None,
        'No test site specified'
    )
    def test_exec_optional_params_site_good_result_success(self):
        params = self.params.copy()
        params['site_identifier'] = self.test_site_identifier
        result = self.test_ocws_instance.study_subject_list_all_by_study(**params)
        self.assertEqual('Success', result['result'])

    @unittest.skipIf(
        owtg.TestGlobals.test_site_identifier is None,
        'No test site specified'
    )
    def test_exec_optional_params_site_wrong_result_fail(self):
        params = self.params.copy()
        params['site_identifier'] = 'no site called this'
        result = self.test_ocws_instance.study_subject_list_all_by_study(**params)
        self.assertEqual('Fail', result['result'])


class TestStudySubjectCreate(owtg.GenericCallFailures):

    def setUp(self):
        if self.subject_create_params is None:
            self.set_subject_create_params()
        self.params = self.subject_create_params.copy()
        # only generate ids for calls that should execute
        if self._testMethodName.startswith('test_exec'):
            self.params = self.set_new_subject_id_params_if_needed(
                self.subject_create_params)
        self.function_to_test_name = 'study_subject_create'
        self.function_to_test_kwargs = self.params

    def test_exec_wrong_params_result_fail(self):
        params = self.params.copy()
        params['study_identifier'] = 'no study called this'
        result = self.test_ocws_instance.study_subject_create(**params)
        self.assertEqual('Fail', result['result'])

    @unittest.skipIf(
        owtg.TestGlobals.test_site_identifier is None,
        'No test site specified'
    )
    def test_exec_optional_params_site_good_result_success(self):
        params = self.params.copy()
        params['site_identifier'] = self.test_site_identifier
        result = self.test_ocws_instance.study_subject_create(**params)
        self.assertEqual('Success', result['result'])

    @unittest.skipIf(
        owtg.TestGlobals.test_site_identifier is None,
        'No test site specified'
    )
    def test_exec_optional_params_site_wrong_result_fail(self):
        params = self.params.copy()
        params['site_identifier'] = 'no site called this'
        result = self.test_ocws_instance.study_subject_create(**params)
        self.assertEqual('Fail', result['result'])


class TestStudySubjectIsSubject(owtg.GenericCallFailures):

    def setUp(self):
        # only make a new subject for calls that should execute
        subject_label = None
        if self._testMethodName.startswith('test_exec'):
            subject_label = self.get_new_subject_label()
        self.params = {
            'study_identifier': self.test_study_identifier,
            'study_subject_id': subject_label,
            'site_identifier': None
        }
        self.function_to_test_name = 'study_subject_is_subject'
        self.function_to_test_kwargs = self.params

    def test_exec_wrong_params_result_fail(self):
        params = self.params.copy()
        params['study_identifier'] = 'no study called this'
        result = self.test_ocws_instance.study_subject_is_subject(**params)
        self.assertEqual('Fail', result['result'])

    @unittest.skipIf(
        owtg.TestGlobals.test_site_identifier is None,
        'No test site specified'
    )
    def test_exec_optional_params_site_good_result_success(self):
        params = self.params.copy()
        params['site_identifier'] = self.test_site_identifier
        result = self.test_ocws_instance.study_subject_is_subject(**params)
        self.assertEqual('Success', result['result'])

    @unittest.skipIf(
        owtg.TestGlobals.test_site_identifier is None,
        'No test site specified'
    )
    def test_exec_optional_params_site_wrong_result_fail(self):
        params = self.params.copy()
        params['site_identifier'] = 'no site called this'
        result = self.test_ocws_instance.study_subject_is_subject(**params)
        self.assertEqual('Fail', result['result'])


class TestEventSchedule(owtg.GenericCallFailures):

    def setUp(self):
        if self.event_schedule_params is None:
            self.set_event_schedule_params()
        self.params = self.event_schedule_params.copy()
        # only make a new subject for calls that should execute
        if self._testMethodName.startswith('test_exec'):
            subject_label = self.get_new_subject_label()
            self.params['study_subject_id'] = subject_label
        self.function_to_test_name = 'event_schedule'
        self.function_to_test_kwargs = self.params

    def test_exec_wrong_params_result_fail(self):
        params = self.params.copy()
        params['study_identifier'] = 'no study called this'
        result = self.test_ocws_instance.event_schedule(**params)
        self.assertEqual('Fail', result['result'])

    @unittest.skipIf(
        owtg.TestGlobals.test_site_identifier is None,
        'No test site specified'
    )
    def test_exec_optional_params_site_good_result_success(self):
        params = self.params.copy()
        params['site_identifier'] = self.test_site_identifier
        result = self.test_ocws_instance.event_schedule(**params)
        self.assertEqual('Success', result['result'])

    @unittest.skipIf(
        owtg.TestGlobals.test_site_identifier is None,
        'No test site specified'
    )
    def test_exec_optional_params_site_wrong_result_fail(self):
        params = self.params.copy()
        params['site_identifier'] = 'no site called this'
        result = self.test_ocws_instance.event_schedule(**params)
        self.assertEqual('Fail', result['result'])


class TestDataImport(owtg.GenericCallFailures):

    def setUp(self):
        if self.study_metadata is None:
            self.get_metadata()
        odm = '<odm/>'
        if self._testMethodName.startswith('test_exec'):
            subject_event = self.get_new_subject_event()
            subject_oid = subject_event['studySubjectOID']
            event_oid = subject_event['eventDefinitionOID']
            event_repeat = subject_event['studyEventOrdinal']
            if self.data_import_first_objects is None:
                self.set_data_import_first_objects()
            odm_tree = {'ODM': {
                'ClinicalData': {
                    '@StudyOID': self.study_oid,
                    '@MetaDataVersionOID': '1',
                    'SubjectData': {
                        '@SubjectKey': subject_oid,
                        'StudyEventData': {
                            '@StudyEventOID': event_oid,
                            '@StudyEventRepeatKey': event_repeat,
                            'FormData': {
                                '@FormOID': self.data_import_first_objects['form'],
                                'ItemGroupData': {
                                    '@ItemGroupOID': self.data_import_first_objects['item_group'],
                                    '@ItemGroupRepeatKey': '1',
                                    '@TransactionType': 'Insert',
                                    'ItemData': {
                                        '@ItemOID': self.data_import_first_objects['item'],
                                        '@Value': self.data_import_first_objects['item_value']
                                    }
                                }
                            }
                        }
                    }
                }}
            }
            odm = xmltodict.unparse(odm_tree)

        self.params = {'odm': odm}
        self.function_to_test_name = 'data_import'
        self.function_to_test_kwargs = self.params

    def test_exec_wrong_params_result_fail(self):
        params = self.params.copy()
        params['odm'] = '<odm/>'
        result = self.test_ocws_instance.data_import(**params)
        self.assertEqual('Fail', result['result'])


if __name__ == '__main__':
    unittest.main()


#ocws_instance = ocws.OpenClinicaWebService(OCWS_URL, USER, PASS)
#study_list_all = ocws_instance.study_list_all()
#print(study_list_all)

#ocws_instance = ocws.OpenClinicaWebService(OCWS_URL, USER, PASS)
#study_get_metadata = ocws_instance.study_get_metadata(STUDY_IDENTIFIER)
#print(study_get_metadata['odm']['ODM']['Study']['@OID'])
#print(type(study_get_metadata))

#ocws_instance = ocws.OpenClinicaWebService(OCWS_URL, USER, PASS)
#study_list_subjects = ocws_instance.study_subject_list_all_by_study(STUDY_IDENTIFIER, with_subject_oids=True)
#print(study_list_subjects)

#ocws_instance = ocws.OpenClinicaWebService(OCWS_URL, USER, PASS)
#is_subject = ocws_instance.study_subject_is_subject(STUDY_IDENTIFIER, 'VHCRP1107-TEST-006')
#print(is_subject)

"""
ocws_instance = ocws.OpenClinicaWebService(OCWS_URL, USER, PASS)
create = ocws_instance.study_subject_create(
    study_identifier="VHCRP1107",
    study_subject_id="VHCRP1107-TEST-006", enrollment_date="2015-02-09",
    gender='m', secondary_label="12345",
    date_or_year_of_birth="1956-01-25"
)
print(create)

ocws_instance = ocws.OpenClinicaWebService(OCWS_URL, USER, PASS)
schedule = ocws_instance.event_schedule(
        study_identifier="XFTEST",
        study_subject_id="1002-TEST-01",
        event_definition_oid="SE_XFTEST",
        event_location="test",
        event_start_date="2015-06-23",
)
print(schedule)
"""

"""
import xml.etree.ElementTree as et

odm = et.Element('ODM')
cd_attrib = {'StudyOID': 'S_XFTEST', 'MetaDataVersionOID': '1'}
cd = et.SubElement(odm, 'ClinicalData', cd_attrib)

subj_attrib = {'SubjectKey': 'SS_1002TEST_5531'}
subj = et.Element('SubjectData', subj_attrib)
cd.insert(0, subj)

event_attrib = {'StudyEventOID': 'SE_XFTEST', 'StudyEventRepeatKey': '2'}
event = et.Element('StudyEventData', event_attrib)
subj.insert(0, event)

form_attrib = {'FormOID': 'F_F1302_FIBROS_0_1'}
form = et.Element('FormData', form_attrib)
event.insert(0, form)

ig_attrib = {'ItemGroupOID': 'IG_F1302_FIBROSCAN',
             'ItemGroupRepeatKey': '1', 'TransactionType': 'Insert'}
ig = et.Element('ItemGroupData', ig_attrib)
form.insert(0, ig)

item_attrib = {'ItemOID': 'I_F1302_FSS', 'Value': '1'}
item = et.Element('ItemData', item_attrib)
ig.insert(0, item)

odm_out = et.tostring(odm).decode('utf-8')

odm = {'ODM': {
    'ClinicalData': {
        '@StudyOID': 'S_XFTEST',
        '@MetaDataVersionOID': '1',
        'SubjectData': {
            '@SubjectKey': 'SS_1002TEST_5531',
            'StudyEventData': {
                '@StudyEventOID': 'SE_XFTEST',
                '@StudyEventRepeatKey': '1',
                'FormData': {
                    '@FormOID': 'F_F1302_FIBROS_0_1',
                    'ItemGroupData': {
                        '@ItemGroupOID': 'IG_F1302_FIBROSCAN',
                        '@ItemGroupRepeatKey': '1',
                        'ItemData': {
                            '@ItemOID': 'I_F1302_FSS',
                            '@Value': '1'
                        }
                    }
                }
            }
        }
    }}

}

import xmltodict as xtd
odm = xtd.unparse(odm)


ocws_instance = ocws.OpenClinicaWebService(OCWS_URL, USER, PASS)
data_import = ocws_instance.data_import(odm)

print(data_import)
"""

"""

#import xmltodict as xtd
#odm = xtd.unparse(odm)

"""

# queries
"""
sslas = ocws.study_subject_list_all_by_study(OCWS_URL, USER, PASS, "VHCRP1002")
sslas_trunk = sslas['studySubjects'][0][0]
subject_id = sslas['studySubjects'][0][0]['label']
subject_initials = sslas['studySubjects'][0][0]['secondaryLabel']
date_of_birth = sslas['studySubjects'][0][0]['subject']['dateOfBirth']
print(subject_id, subject_initials, date_of_birth)
#print(sslas_trunk)

study = ocws.study_list_all(OCWS_URL, USER, PASS)
#print(study)

metadata = ocws.study_get_metadata(OCWS_URL, USER, PASS, "XFTEST")
#print(metadata)

is_subject = ocws.study_subject_exists(
    OCWS_URL, USER, PASS, study_identifier="VHCRP1107",
    study_subject_id="VHCRP1107-TEST-002", site_identifier="1107-61302")
print(is_subject)
"""

"""

# have effects

schedule = ocws.event_schedule(
        OCWS_URL, USER, PASS,
        study_identifier="XFTEST",
        study_subject_id="1002-TEST-01",
        event_definition_oid="SE_XFTEST",
        event_location="",
        event_start_date="2015-06-23",
)
#print(schedule)

create = ocws.study_subject_create(
    OCWS_URL, USER, PASS, study_identifier="VHCRP1107",
    study_subject_id="VHCRP1107-TEST-003", enrollment_date="2015-02-09",
    gender='m', secondary_label="12345", site_identifier="1107-61302",
    date_or_year_of_birth="1956-01-25"
)
print(create)
"""


