<?php
// Class extension to remove motm encoding from response, if any
class MTOMSoapClient extends SoapClient {
	public function __doRequest($request, $location, $action, $version, $one_way) {
		$response = parent::__doRequest ( $request, $location, $action, $version, $one_way );
		// if resposnse content type is mtom strip away everything but the xml.
		if (strpos ( $response, "Content-Type: application/xop+xml" ) !== false) {
			$SoapEnvStart = strpos ( $response, '<SOAP-ENV:Envelope' );
			$SoapEnvEnd = strpos ( $response, '</SOAP-ENV:Envelope>' ) + 20;
			// 20 chars in strpos needle
			$response = substr ( $response, $SoapEnvStart, $SoapEnvEnd - $SoapEnvStart );
		}
		return $response;
	}
}
// Class extension for adding WSSE Security Header
class WSSESecurityHeader extends SoapHeader {
	public function __construct($username, $password) {
		$wsseNamespace = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
		$wssePasswordNS = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText';
		$wsseUserVar = new SoapVar ( $username, XSD_STRING, null, null, 'Username', $wsseNamespace );
		$wssePassVar = new SoapVar ( $password, XSD_STRING, type, $wssePasswordNS, 'Password', $wsseNamespace );
		$wsseUserPassVar = new SoapVar ( array (
				$wsseUserVar,
				$wssePassVar 
		), SOAP_ENC_OBJECT, null, null, 'UsernameToken', $wsseNamespace );
		$security = new SoapVar ( array (
				$wsseUserPassVar 
		), SOAP_ENC_OBJECT );
		parent::SoapHeader ( $wsseNamespace, 'Security', $security, 1 );
	}
}
// Class for calling OpenClinica SOAP Web Services
class OpenClinicaSoapWebService {
	// Variables for the SoapClient object used in the requests
	private $ocWsInstanceURL;
	private $ocUserName;
	private $ocPassword;
	private $WSSESecurityHeader;
	// WSDL locations within a webservice instance per OpenClinica documentation
	const WSDL_STUDY = 'ws/study/v1/studyWsdl.wsdl';
	const WSDL_SED = 'ws/studyEventDefinition/v1/studyEventDefinitionWsdl.wsdl';
	const WSDL_DATA = 'ws/data/v1/dataWsdl.wsdl';
	const WSDL_EVENT = 'ws/event/v1/eventWsdl.wsdl';
	const WSDL_SSUBJ = 'ws/studySubject/v1/studySubjectWsdl.wsdl';
	const NS_OCBEANS = 'http://openclinica.org/ws/beans';
	const NS_ODM = 'http://www.cdisc.org/ns/odm/v1.3';
	// Set class properties
	public function __construct($ocWsInstanceURL, $ocUserName, $ocPassword) {
		$this->ocWsInstanceURL = $ocWsInstanceURL;
		$this->ocUserName = $ocUserName;
		$this->ocPassword = $ocPassword;
		$this->WSSESecurityHeader = new WSSESecurityHeader ( $this->ocUserName, $this->ocPassword );
	}
	private function callSoapClient($ocWsdlLocation, $ocWsdlNameSpace, $ocSoapFunction, $ocSoapArguments) {
		// trace must be on so that __getLastResponse can be used,
		// since the SoapClient doesn't seem to correctly parse
		// the namespaced responses
		$ocSoapClient = new MTOMSoapClient ( $ocWsdlLocation, array (
				'trace' => 1 
		) );
		$ocSoapClientHeader = $this->WSSESecurityHeader;
		$ocSoapClient->__setSoapHeaders ( $ocSoapClientHeader );
		try {
			$ocSoapClient->__soapCall ( $ocSoapFunction, array (
					$ocSoapArguments 
			) );
			$response = simplexml_load_string ( $ocSoapClient->__getLastResponse () );
			$response->registerXPathNamespace ( 'v1', $ocWsdlNameSpace );
			$response->registerXPathNamespace ( 'odm', self::NS_ODM );
			// echo $ocSoapClient->__getLastRequest();
			// echo $ocSoapClient->__getLastResponse();
			return $response;
		} catch ( SoapFault $soapfault ) {
			echo 'last request: ' . $ocSoapClient->__getLastRequest ();
			echo 'last response: ' . $ocSoapClient->__getLastResponse ();
			die ( "soapfault: " . $soapfault );
		}
	}
	// query that returns result then studies node with details of studies/sites
	// to which the user has access
	public function studyListAll() {
		$ocWsdlLocation = $this->ocWsInstanceURL . self::WSDL_STUDY;
		$ocWsdlNameSpace = 'http://openclinica.org/ws/study/v1';
		$ocSoapFunction = 'listAll';
		$ocSoapArguments = 'listAllRequest';
		$response = $this->callSoapClient ( $ocWsdlLocation, $ocWsdlNameSpace, $ocSoapFunction, $ocSoapArguments );
		return $response;
	}
	// query that returns result then odm node with the requested study metadata
	public function studyGetMetadata($ocUniqueProtocolId) {
		$ocWsdlLocation = $this->ocWsInstanceURL . self::WSDL_STUDY;
		$ocWsdlNameSpace = 'http://openclinica.org/ws/study/v1';
		$ocSoapFunction = 'getMetadata';
		$ocSoapArgIdentifier = new SoapVar ( $ocUniqueProtocolId, XSD_STRING, null, null, 'identifier', self::NS_OCBEANS );
		$ocSoapArgStudyRef = new SoapVar ( array (
				$ocSoapArgIdentifier 
		), SOAP_ENC_OBJECT, null, null, 'studyRef', self::NS_OCBEANS );
		$ocSoapArgStudyMetaData = new SoapVar ( $ocSoapArgStudyRef, SOAP_ENC_OBJECT, null, $ocWsdlNameSpace, 'studyMetadata', $ocWsdlNameSpace );
		$ocSoapArguments = new SoapVar ( array (
				$ocSoapArgStudyMetaData 
		), SOAP_ENC_OBJECT );
		$response = $this->callSoapClient ( $ocWsdlLocation, $ocWsdlNameSpace, $ocSoapFunction, $ocSoapArguments );
		return $response;
	}
	// create the studyRef and/or siteRef SoapVars, common to most calls
	private function soapVarStudyRefSiteRef($ocUniqueProtocolId, $ocUniqueProtocolIDSiteRef) {
		// ocSoapVarUniqueProtocolId is needed for both if,else cases below
		$ocSoapVarUniqueProtocolId = new SoapVar ( $ocUniqueProtocolId, XSD_STRING, null, self::NS_OCBEANS, 'identifier', self::NS_OCBEANS );
		if (preg_match ( '/\S/', $ocUniqueProtocolIDSiteRef ) || isset ( $ocUniqueProtocolIDSiteRef )) {
			// if a siteRef has some non-whitespace content, or isSet
			// include siteRef node (empty() was not working for '' string)
			// must wrap single xsd_string in soapvar(array(obj),seo)
			$ocSoapVarUniqueProtocolIDSiteRef = new SoapVar ( $ocUniqueProtocolIDSiteRef, XSD_STRING, null, self::NS_OCBEANS, 'identifier', self::NS_OCBEANS );
			$ocSoapVarUniqueProtocolIDSiteRefSEO = new SoapVar ( array (
					$ocSoapVarUniqueProtocolIDSiteRef 
			), SOAP_ENC_OBJECT );
			$ocSoapVarUniqueProtocolIDSiteRefNode = new SoapVar ( $ocSoapVarUniqueProtocolIDSiteRefSEO, SOAP_ENC_OBJECT, null, self::NS_OCBEANS, 'siteRef', self::NS_OCBEANS );
			// must use site's xsd_string soapvar here, not seo-wrapped one
			$ocSoapVarStudyRefArray = array (
					$ocSoapVarUniqueProtocolId,
					$ocSoapVarUniqueProtocolIDSiteRefNode 
			);
			$ocSoapVarStudyRef = new SoapVar ( $ocSoapVarStudyRefArray, SOAP_ENC_OBJECT, null, self::NS_OCBEANS, 'studyRef', self::NS_OCBEANS );
		} else {
			// otherwise set the studyRef node with just the study ID
			$ocSoapVarUniqueProtocolIdSEO = new SoapVar ( array (
					$ocSoapVarUniqueProtocolId 
			), SOAP_ENC_OBJECT );
			$ocSoapVarStudyRef = new SoapVar ( $ocSoapVarUniqueProtocolIdSEO, SOAP_ENC_OBJECT, null, self::NS_OCBEANS, 'studyRef', self::NS_OCBEANS );
		}
		return $ocSoapVarStudyRef;
	}
	// inserts subject to specified study/site and returns result
	public function subjectCreateSubject($ocUniqueProtocolId, $ocUniqueProtocolIDSiteRef, $ocStudySubjectId, $ocSecondaryLabel, $ocEnrollmentDate, $ocPersonID, $ocGender, $ocDateOfBirth) {
		$ocWsdlLocation = $this->ocWsInstanceURL . self::WSDL_SSUBJ;
		$ocWsdlNameSpace = 'http://openclinica.org/ws/studySubject/v1';
		$ocSoapFunction = 'create';
		// studyRef node
		$ocSoapVarStudyRef = $this->soapVarStudyRefSiteRef ( $ocUniqueProtocolId, $ocUniqueProtocolIDSiteRef );
		// subject node
		$ocSoapVarPersonID = new SoapVar ( $ocPersonID, XSD_STRING, null, null, 'uniqueIdentifier', self::NS_OCBEANS );
		$ocSoapVarGender = new SoapVar ( $ocGender, XSD_STRING, null, null, 'gender', self::NS_OCBEANS );
		//if year of birth was passed
		if (strlen($ocDateOfBirth)==4){
			$ocSoapVarDateOfBirth = new SoapVar ( $ocDateOfBirth, XSD_STRING, null, null, 'yearOfBirth', self::NS_OCBEANS );
		}
		else {
			$ocSoapVarDateOfBirth = new SoapVar ( $ocDateOfBirth, XSD_DATE, null, null, 'dateOfBirth', self::NS_OCBEANS );
		}
		//$ocSoapVarDateOfBirth = new SoapVar ( $ocDateOfBirth, XSD_DATE, null, null, 'dateOfBirth', self::NS_OCBEANS );
		$ocSoapVarSubject = new SoapVar ( array (
				$ocSoapVarPersonID,
				$ocSoapVarGender,
				$ocSoapVarDateOfBirth 
		), SOAP_ENC_OBJECT, null, self::NS_OCBEANS, 'subject', self::NS_OCBEANS );
		// studySubject node
		$ocSoapVarStudySubjectID = new SoapVar ( $ocStudySubjectId, XSD_STRING, null, null, 'label', self::NS_OCBEANS );
		$ocSoapVarSecondaryLabel = new SoapVar ( $ocSecondaryLabel, XSD_STRING, null, null, 'secondaryLabel', self::NS_OCBEANS );
		$ocSoapVarEnrollmentDate = new SoapVar ( $ocEnrollmentDate, XSD_DATE, null, null, 'enrollmentDate', self::NS_OCBEANS );
		$ocSoapVarStudySubject = new SoapVar ( array (
				$ocSoapVarStudySubjectID,
				$ocSoapVarSecondaryLabel,
				$ocSoapVarEnrollmentDate,
				$ocSoapVarSubject,
				$ocSoapVarStudyRef 
		), SOAP_ENC_OBJECT, null, $ocWsdlNameSpace, 'studySubject', $ocWsdlNameSpace );
		$ocSoapArguments = new SoapVar ( array (
				$ocSoapVarStudySubject 
		), SOAP_ENC_OBJECT );
		$response = $this->callSoapClient ( $ocWsdlLocation, $ocWsdlNameSpace, $ocSoapFunction, $ocSoapArguments );
		return $response;
	}
	// query that returns result then studySubjects node with the details for
	// subjects at the requested study/site
	public function subjectListAllByStudy($ocUniqueProtocolId, $ocUniqueProtocolIDSiteRef) {
		// listAllByStudy expects no blank personId,DoB,Sex in the instance
		$ocWsdlLocation = $this->ocWsInstanceURL . self::WSDL_SSUBJ;
		$ocWsdlNameSpace = 'http://openclinica.org/ws/studySubject/v1';
		$ocSoapFunction = 'listAllByStudy';
		$ocSoapVarStudyRef = $this->soapVarStudyRefSiteRef ( $ocUniqueProtocolId, $ocUniqueProtocolIDSiteRef );
		$ocSoapArguments = new SoapVar ( array (
				$ocSoapVarStudyRef 
		), SOAP_ENC_OBJECT );
		$response = $this->callSoapClient ( $ocWsdlLocation, $ocWsdlNameSpace, $ocSoapFunction, $ocSoapArguments );
		return $response;
	}
	// query that returns result then studySubjects node with the details for
	// subjects at the requested study/site
	public function subjectIsStudySubject($ocUniqueProtocolId, $ocUniqueProtocolIDSiteRef, $ocStudySubjectId) {
		$ocWsdlLocation = $this->ocWsInstanceURL . self::WSDL_SSUBJ;
		$ocWsdlNameSpace = 'http://openclinica.org/ws/studySubject/v1';
		$ocSoapFunction = 'isStudySubject';
		$ocSoapVarStudySubjectID = new SoapVar ( $ocStudySubjectId, XSD_STRING, null, null, 'label', self::NS_OCBEANS );
		$ocSoapVarStudyRef = $this->soapVarStudyRefSiteRef ( $ocUniqueProtocolId, $ocUniqueProtocolIDSiteRef );
		$ocSoapVarStudySubject = new SoapVar ( array (
				$ocSoapVarStudySubjectID,
				$ocSoapVarStudyRef 
		), SOAP_ENC_OBJECT, null, $ocWsdlNameSpace, 'studySubject', $ocWsdlNameSpace );
		$ocSoapArguments = new SoapVar ( array (
				$ocSoapVarStudySubject 
		), SOAP_ENC_OBJECT );
		$response = $this->callSoapClient ( $ocWsdlLocation, $ocWsdlNameSpace, $ocSoapFunction, $ocSoapArguments );
		return $response;
	}
	// inserts event for specified subject and returns result
	public function eventSchedule($ocStudySubjectId, $ocEventOID, $ocEventLocation, $ocEventStartDate, $ocEventStartTime, $ocEventEndDate, $ocEventEndTime, $ocUniqueProtocolId, $ocUniqueProtocolIDSiteRef) {
		$ocWsdlLocation = $this->ocWsInstanceURL . self::WSDL_EVENT;
		$ocWsdlNameSpace = 'http://openclinica.org/ws/event/v1';
		$ocSoapFunction = 'schedule';
		$ocSoapVarStudySubjectID = new SoapVar ( $ocStudySubjectId, XSD_STRING, null, null, 'label', self::NS_OCBEANS );
		$ocSoapVarStudySubjectRef = new SoapVar ( array (
				$ocSoapVarStudySubjectID 
		), SOAP_ENC_OBJECT, null, self::NS_OCBEANS, 'studySubjectRef', self::NS_OCBEANS );
		$ocSoapVarStudyRef = $this->soapVarStudyRefSiteRef ( $ocUniqueProtocolId, $ocUniqueProtocolIDSiteRef );
		$ocSoapVarEventDefinitionOID = new SoapVar ( $ocEventOID, XSD_STRING, null, null, 'eventDefinitionOID', self::NS_OCBEANS );
		$ocSoapVarEventLocation = new SoapVar ( $ocEventLocation, XSD_STRING, null, null, 'location', self::NS_OCBEANS );
		$ocSoapVarEventStartDate = new SoapVar ( $ocEventStartDate, XSD_DATE, null, null, 'startDate', self::NS_OCBEANS );
		$ocSoapVarEventStartTime = new SoapVar ( $ocEventStartTime, XSD_STRING, null, null, 'startTime', self::NS_OCBEANS );
		$ocSoapVarEventEndDate = new SoapVar ( $ocEventEndDate, XSD_DATE, null, null, 'endDate', self::NS_OCBEANS );
		$ocSoapVarEventEndTime = new SoapVar ( $ocEventEndTime, XSD_STRING, null, null, 'endTime', self::NS_OCBEANS );
		$ocSoapVarEvent = new SoapVar ( array (
				$ocSoapVarStudySubjectRef,
				$ocSoapVarStudyRef,
				$ocSoapVarEventDefinitionOID,
				$ocSoapVarEventLocation,
				$ocSoapVarEventStartDate,
				$ocSoapVarEventStartTime,
				$ocSoapVarEventEndDate,
				$ocSoapVarEventEndTime 
		), SOAP_ENC_OBJECT, null, $ocWsdlNameSpace, 'event', $ocWsdlNameSpace );
		$ocSoapArguments = new SoapVar ( array (
				$ocSoapVarEvent 
		), SOAP_ENC_OBJECT );
		$response = $this->callSoapClient ( $ocWsdlLocation, $ocWsdlNameSpace, $ocSoapFunction, $ocSoapArguments );
		return $response;
	}
	// inserts crf data for a specified study and/or site
	public function dataImport($ocODMClinicalData) {
		$ocWsdlLocation = $this->ocWsInstanceURL . self::WSDL_DATA;
		$ocWsdlNameSpace = 'http://openclinica.org/ws/data/v1';
		$ocSoapFunction = 'import';
		$ocODMClinicalDataCDATA = '<![CDATA[' . $ocODMClinicalData . ']]>';
		$ocSoapVarODM = new SoapVar ( $ocODMClinicalData, XSD_ANYXML, null, null, 'ODM', null );
		$ocSoapArguments = new SoapVar ( array (
				$ocSoapVarODM 
		), SOAP_ENC_OBJECT );
		$response = $this->callSoapClient ( $ocWsdlLocation, $ocWsdlNameSpace, $ocSoapFunction, $ocSoapArguments );
		return $response;
	}
	// query that returns result then details of
	// event definitions in the requested study/site
	public function StudyEventDefinitionListAll($ocUniqueProtocolId) {
		$ocWsdlLocation = $this->ocWsInstanceURL . self::WSDL_SED;
		$ocWsdlNameSpace = 'http://openclinica.org/ws/studyEventDefinition/v1';
		$ocSoapFunction = 'listAll';
		$ocSoapVarStudyRef = $this->soapVarStudyRefSiteRef ( $ocUniqueProtocolId );
		$ocSoapVarSEDListAll = new SoapVar ( array (
				$ocSoapVarStudyRef 
		), SOAP_ENC_OBJECT, null, $ocWsdlNameSpace, 'studyEventDefinitionListAll', $ocWsdlNameSpace );
		$ocSoapArguments = new SoapVar ( array (
				$ocSoapVarSEDListAll 
		), SOAP_ENC_OBJECT );
		$response = $this->callSoapClient ( $ocWsdlLocation, $ocWsdlNameSpace, $ocSoapFunction, $ocSoapArguments );
		return $response;
	}
}
?>