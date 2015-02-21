<?php

require_once "OpenClinicaSoapWebService.php";
require_once "OpenClinicaODMFunctions.php";

// variables for testing that would otherwise be passed in by the application

$ocUserName = "lstevens";
$ocPassword = "sha1password";
$ocWsInstanceURL = "https://localhost:8443/OpenClinica3141-ws/";
$ocUniqueProtocolId = "VHCRP1107";
$ocUniqueProtocolIDSiteRef = '1107-61302';
$ocStudySubjectId = '1107-TEST-07';
$ocSecondaryLabel = 'AB-CD';
$ocEnrollmentDate = '2014-05-19';
$ocPersonID = '1107-TEST-07';
$ocGender = 'm';
$ocDateOfBirth = '1989-12-16';
$ocEventOID = array(
        'SE_V1107_SCREENING',
        'SE_V1107_BASELINE',
        'SE_V1107_W2',
        'SE_V1107_W4'
);
$ocEventLocation = 'Sydney';
$ocEventStartDate = '2012-02-02';
$ocEventStartTime = '12:15';
$ocEventEndDate = '2012-02-06';
$ocEventEndTime = '19:26';

$itemGroupRow1 = new ocODMitemGroupData('IG_C1107_SCREEN', 1,
        array(
                new ocODMitemData('I_C1107_VISIT_DT', '2014-05-17'),
                new ocODMitemData('I_C1107_INC1_CHR', 0)
        ));
$itemGroupRow2 = new ocODMitemGroupData('IG_C1107_SCREEN', 2,
        array(
                new ocODMitemData('I_C1107_VISIT_DT', '2014-05-16'),
                new ocODMitemData('I_C1107_INC1_CHR', 1)
        ));

$odm = array(
        new ocODMclinicalData('S_V1107', 1,
                array(
                        new ocODMsubjectData('SS_1107TEST_2732',
                                array(
                                        new ocODMstudyEventData(
                                                'SE_V1107_SCREENING', 1,
                                                array(
                                                        new ocODMformData(
                                                                'F_C1107_SCREEN_1',
                                                                array(
                                                                        $itemGroupRow1,
                                                                        $itemGroupRow2
                                                                ))
                                                ))
                                ))
                ))
);

// test calls using the above variables

echo '--start test calls--' . "\n";

$test = new OpenClinicaSoapWebService($ocWsInstanceURL, $ocUserName, $ocPassword);

$StudyEventDefinitionListAll = $test->StudyEventDefinitionListAll(
        $ocUniqueProtocolId);
echo 'StudyEventDefinitionListAll: ' .
         $StudyEventDefinitionListAll->xpath('//v1:result')[0] . "\n";

$studyListAll = $test->studyListAll();
echo 'listAll: ' . $studyListAll->xpath('//v1:result')[0] . "\n";

$getMetadata = $test->studyGetMetadata($ocUniqueProtocolId);
echo 'getMetadata: ' . $getMetadata->xpath('//v1:result')[0] . "\n";

$createSubject = $test->subjectCreateSubject($ocUniqueProtocolId, 
        $ocUniqueProtocolIDSiteRef, $ocStudySubjectId, $ocSecondaryLabel, 
        $ocEnrollmentDate, $ocPersonID, $ocGender, $ocDateOfBirth);
echo 'createSubject: ' . $createSubject->xpath('//v1:result')[0] . "\n";

$listAllByStudy = $test->subjectListAllByStudy($ocUniqueProtocolId, 
        $ocUniqueProtocolIDSiteRef);
echo 'listAllByStudy: ' . $listAllByStudy->xpath('//v1:result')[0] . "\n";

$isStudySubject = $test->subjectIsStudySubject($ocUniqueProtocolId, 
        $ocUniqueProtocolIDSiteRef, $ocStudySubjectId);
echo 'isStudySubject: ' . $isStudySubject->xpath('//v1:result')[0] . "\n";

$schedule = $test->eventSchedule($ocStudySubjectId, $ocEventOID[2], 
        $ocEventLocation, $ocEventStartDate, $ocEventStartTime, $ocEventEndDate, 
        $ocEventEndTime, $ocUniqueProtocolId, $ocUniqueProtocolIDSiteRef);
echo 'schedule: ' . $schedule->xpath('//v1:result')[0] . "\n";

$import = $test->dataImport(ocODMtoXML($odm));
echo 'import: ' . $import->xpath('//v1:result')[0] . "\n";

echo '--end test calls--';

/*
 * how to get a series of nodes with simplexml->xpath(): 
 * foreach ($studyListAll->xpath('//v1:name') as $study_name) { 
 * echo '<p>' . $study_name . '</p>'; }
 * how to parse the getMetadata ODM (which is escaped xml):
 * $odmMetaRaw = $getMetadata->xpath('//v1:odm');
 * $odmMeta = simplexml_load_string($odmMetaRaw[0]);
 * $odmMeta->registerXPathNamespace('odm', OpenClinicaSoapWebService::NS_ODM);
 * foreach ($odmMeta->xpath('//odm:StudyName') as $study_name) {
 * echo '<p>' . $study_name . '</p>'; }
 * 
 * example debug output:
 * --start test calls--
 * StudyEventDefinitionListAll: Success
 * listAll: Success
 * getMetadata: Success
 * createSubject: Fail
 * listAllByStudy: Success
 * isStudySubject: Success
 * schedule: Fail
 * import: Success
 * --end test calls--
 */
?>