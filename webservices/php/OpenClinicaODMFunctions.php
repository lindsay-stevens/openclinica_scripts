<?php
// Classes to build ODM structure for import to OpenClinica
// Function to convert to equivalent XML
// Modified to be able to add new items/groups/forms/events/subjects to the xml
class ocODMclinicalData {
	public $studyOID;
	public $metaDataVersionOID;
	public $subjectData = array ();
	public function __construct($studyOID, $metaDataVersionOID, $subjectData) {
		$this->studyOID = $studyOID;
		$this->metaDataVersionOID = $metaDataVersionOID;
		$this->subjectData = $subjectData;
	}
	public function add_subject($subject, $event,$repeatkey, $form, $formstatus, $group, $grouprepkey, $item, $value){
		if ( isset($this->subjectData[$subject]) ) {
			$this->subjectData[$subject]->add_event($event, $repeatkey, $form, $formstatus, $group, $grouprepkey, $item, $value);
		}
		else {
			$this->subjectData[$subject] = new ocODMsubjectData($subject,array());
			$this->subjectData[$subject]->add_event($event, $repeatkey, $form, $formstatus, $group, $grouprepkey, $item, $value);
		}
	
	}
}
class ocODMsubjectData {
	public $subjectKey;
	public $studyEventData = array ();
	public function __construct($subjectKey, $studyEventData) {
		$this->subjectKey = $subjectKey;
		$this->studyEventData = $studyEventData;
	}
	public function add_event($event, $repeatkey, $form, $formstatus, $group, $grouprepkey, $item, $value){
		if ( isset($this->studyEventData["".$event.$repeatkey]))
			$this->studyEventData["".$event.$repeatkey]->add_form($form, $formstatus, $group, $grouprepkey, $item, $value);
		else {
			$this->studyEventData["".$event.$repeatkey] = new ocODMstudyEventData($event, $repeatkey, array());
			$this->studyEventData["".$event.$repeatkey]->add_form($form, $formstatus, $group, $grouprepkey, $item, $value);
		}
	
	}
}
class ocODMstudyEventData {
	public $studyEventOID;
	public $studyEventRepeatKey;
	public $formData = array ();
	public function __construct($studyEventOID, $studyEventRepeatKey, $formData) {
		$this->studyEventOID = $studyEventOID;
		$this->studyEventRepeatKey = $studyEventRepeatKey;
		$this->formData = $formData;
	}
	public function add_form($form, $formstatus, $group, $grouprepkey, $item, $value){
		if ( isset($this->formData[$form]) )
			$this->formData[$form]->add_group($group, $grouprepkey, $item, $value);
		else {
			$this->formData[$form] = new ocODMformData($form, $formstatus, array());
			$this->formData[$form]->add_group($group, $grouprepkey, $item, $value);
		}
	
	}
}
class ocODMformData {
	public $formOID;
	public $formStatus;
	public $itemGroupData = array ();
	public function __construct($formOID, $formstatus, $itemGroupData) {
		$this->formOID = $formOID;
		$this->formStatus = $formstatus;
		$this->itemGroupData = $itemGroupData;
	}
	public function add_group($group,$grouprepkey, $item, $value){
		if ( isset($this->itemGroupData["".$group.$grouprepkey]))
			$this->itemGroupData["".$group.$grouprepkey]->add_item($item, $value);
		else {
			$this->itemGroupData["".$group.$grouprepkey] = new ocODMitemGroupData($group, $grouprepkey, array());
			$this->itemGroupData["".$group.$grouprepkey]->add_item($item, $value);
		}
	}
}
class ocODMitemGroupData {
	public $itemGroupOID;
	public $itemGroupRepeatKey;
	public $itemData = array ();
	public function __construct($itemGroupOID, $itemGroupRepeatKey, $itemData) {
		$this->itemGroupOID = $itemGroupOID;
		$this->itemGroupRepeatKey = $itemGroupRepeatKey;
		$this->itemData = $itemData;
	}
	public function add_item($item, $value){
		if ( !isset($this->itemData[$item]) ){
			$this->itemData[$item] = new ocODMitemData($item, $value);
		}
			
	}
}
class ocODMitemData {
	public $itemOID;
	public $itemValue;
	public function __construct($itemOID, $itemValue) {
		$this->itemOID = $itemOID;
		$this->itemValue = $itemValue;
	}
}
// converts ODM as nested arrays of classes into equivalent XML
function ocODMtoXML($odm) {
	$ocODMDoc = new DOMDocument ();
	$ocODMElementODM = $ocODMDoc->createElement ( 'ODM' );
	$ocODMElementODM->setAttribute('xmlns',"http://www.cdisc.org/ns/odm/v1.3");
	$ocODMElementODM->setAttribute('xmlns:OpenClinica',"http://www.openclinica.org/ns/odm_ext_v130/v3.1");
	$ocODMDoc->appendChild ( $ocODMElementODM );
	foreach ( $odm as $clinicalData ) {
		$ocODMElementClinicalData = $ocODMDoc->createElement ( 'ClinicalData' );
		$ocODMElementClinicalData->setAttribute ( 'StudyOID', $clinicalData->studyOID );
		$ocODMElementClinicalData->setAttribute ( 'MetaDataVersionOID', $clinicalData->metaDataVersionOID );
		$ocODMElementODM->appendChild ( $ocODMElementClinicalData );
		foreach ( $clinicalData->subjectData as $subjectData ) {
			$ocODMElementSubjectData = $ocODMDoc->createElement ( 'SubjectData' );
			$ocODMElementSubjectData->setAttribute ( 'SubjectKey', $subjectData->subjectKey );
			$ocODMElementClinicalData->appendChild ( $ocODMElementSubjectData );
			foreach ( $subjectData->studyEventData as $studyEventData ) {
				$ocODMElementStudyEventData = $ocODMDoc->createElement ( 'StudyEventData' );
				$ocODMElementStudyEventData->setAttribute ( 'StudyEventOID', $studyEventData->studyEventOID );
				$ocODMElementStudyEventData->setAttribute ( 'StudyEventRepeatKey', $studyEventData->studyEventRepeatKey );
				$ocODMElementSubjectData->appendChild ( $ocODMElementStudyEventData );
				foreach ( $studyEventData->formData as $formData ) {
					$ocODMElementFormData = $ocODMDoc->createElement ( 'FormData' );
					$ocODMElementFormData->setAttribute ( 'FormOID', $formData->formOID );
					if($formData->formStatus == "dataentrystarted"){
						$ocODMElementFormData->setAttribute ('OpenClinica:Status',"initial data entry");
					}
					$ocODMElementStudyEventData->appendChild ( $ocODMElementFormData );
					foreach ( $formData->itemGroupData as $itemGroupData ) {
						$ocODMElementItemGroupData = $ocODMDoc->createElement ( 'ItemGroupData' );
						$ocODMElementItemGroupData->setAttribute ( 'ItemGroupOID', $itemGroupData->itemGroupOID );
						$ocODMElementItemGroupData->setAttribute ( 'ItemGroupRepeatKey', $itemGroupData->itemGroupRepeatKey );
						$ocODMElementItemGroupData->setAttribute ( 'TransactionType', 'Insert' );
						$ocODMElementFormData->appendChild ( $ocODMElementItemGroupData );
						foreach ( $itemGroupData->itemData as $itemData ) {
							$ocODMElementItemData = $ocODMDoc->createElement ( 'ItemData' );
							$ocODMElementItemData->setAttribute ( 'ItemOID', $itemData->itemOID );
							$ocODMElementItemData->setAttribute ( 'Value', $itemData->itemValue );
							$ocODMElementItemGroupData->appendChild ( $ocODMElementItemData );
						}
					}
				}
			}
		}
	}
	$ocODMNode = $ocODMDoc->saveXML ( $ocODMElementODM );
	return $ocODMNode;
}
?>