<?php
// Classes to build ODM structure for import to OpenClinica
// Function to convert to equivalent XML

class ocODMclinicalData
{

    public $studyOID;

    public $metaDataVersionOID;

    public $subjectData = array();

    public function __construct ($studyOID, $metaDataVersionOID, $subjectData)
    {
        $this->studyOID = $studyOID;
        $this->metaDataVersionOID = $metaDataVersionOID;
        $this->subjectData = $subjectData;
    }
}

class ocODMsubjectData
{

    public $subjectKey;

    public $studyEventData = array();

    public function __construct ($subjectKey, $studyEventData)
    {
        $this->subjectKey = $subjectKey;
        $this->studyEventData = $studyEventData;
    }
}

class ocODMstudyEventData
{

    public $studyEventOID;

    public $studyEventRepeatKey;

    public $formData = array();

    public function __construct ($studyEventOID, $studyEventRepeatKey, $formData)
    {
        $this->studyEventOID = $studyEventOID;
        $this->studyEventRepeatKey = $studyEventRepeatKey;
        $this->formData = $formData;
    }
}

class ocODMformData
{

    public $formOID;

    public $itemGroupData = array();

    public function __construct ($formOID, $itemGroupData)
    {
        $this->formOID = $formOID;
        $this->itemGroupData = $itemGroupData;
    }
}

class ocODMitemGroupData
{

    public $itemGroupOID;

    public $itemGroupRepeatKey;

    public $itemData = array();

    public function __construct ($itemGroupOID, $itemGroupRepeatKey, $itemData)
    {
        $this->itemGroupOID = $itemGroupOID;
        $this->itemGroupRepeatKey = $itemGroupRepeatKey;
        $this->itemData = $itemData;
    }
}

class ocODMitemData
{

    public $itemOID;

    public $itemValue;

    public function __construct ($itemOID, $itemValue)
    {
        $this->itemOID = $itemOID;
        $this->itemValue = $itemValue;
    }
}

// converts ODM as nested arrays of classes into equivalent XML
function ocODMtoXML ($odm)
{
    $ocODMDoc = new DOMDocument();
    $ocODMElementODM = $ocODMDoc->createElement('ODM');
    $ocODMDoc->appendChild($ocODMElementODM);
    
    foreach ($odm as $clinicalData) {
        
        $ocODMElementClinicalData = $ocODMDoc->createElement('ClinicalData');
        $ocODMElementClinicalData->setAttribute('StudyOID', 
                $clinicalData->studyOID);
        $ocODMElementClinicalData->setAttribute('MetaDataVersionOID', 
                $clinicalData->metaDataVersionOID);
        $ocODMElementODM->appendChild($ocODMElementClinicalData);
        
        foreach ($clinicalData->subjectData as $subjectData) {
            
            $ocODMElementSubjectData = $ocODMDoc->createElement('SubjectData');
            $ocODMElementSubjectData->setAttribute('SubjectKey', 
                    $subjectData->subjectKey);
            $ocODMElementClinicalData->appendChild($ocODMElementSubjectData);
            
            foreach ($subjectData->studyEventData as $studyEventData) {
                
                $ocODMElementStudyEventData = $ocODMDoc->createElement(
                        'StudyEventData');
                $ocODMElementStudyEventData->setAttribute('StudyEventOID', 
                        $studyEventData->studyEventOID);
                $ocODMElementStudyEventData->setAttribute('StudyEventRepeatKey', 
                        $studyEventData->studyEventRepeatKey);
                $ocODMElementSubjectData->appendChild(
                        $ocODMElementStudyEventData);
                
                foreach ($studyEventData->formData as $formData) {
                    
                    $ocODMElementFormData = $ocODMDoc->createElement('FormData');
                    $ocODMElementFormData->setAttribute('FormOID', 
                            $formData->formOID);
                    $ocODMElementStudyEventData->appendChild(
                            $ocODMElementFormData);
                    
                    foreach ($formData->itemGroupData as $itemGroupData) {
                        
                        $ocODMElementItemGroupData = $ocODMDoc->createElement(
                                'ItemGroupData');
                        $ocODMElementItemGroupData->setAttribute('ItemGroupOID', 
                                $itemGroupData->itemGroupOID);
                        $ocODMElementItemGroupData->setAttribute(
                                'ItemGroupRepeatKey', 
                                $itemGroupData->itemGroupRepeatKey);
                        $ocODMElementItemGroupData->setAttribute(
                                'TransactionType', 'Insert');
                        $ocODMElementFormData->appendChild(
                                $ocODMElementItemGroupData);
                        
                        foreach ($itemGroupData->itemData as $itemData) {
                            
                            $ocODMElementItemData = $ocODMDoc->createElement(
                                    'ItemData');
                            $ocODMElementItemData->setAttribute('ItemOID', 
                                    $itemData->itemOID);
                            $ocODMElementItemData->setAttribute('Value', 
                                    $itemData->itemValue);
                            $ocODMElementItemGroupData->appendChild(
                                    $ocODMElementItemData);
                        }
                    }
                }
            }
        }
    }
    $ocODMNode = $ocODMDoc->saveXML($ocODMElementODM);
    return $ocODMNode;
}

?>