<?php
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
	public $ocWsInstanceURL;
	public $ocUserName;
	public $ocPassword;
	
	// WSDL locations within a webservice instance per OpenClinica documentation
	const WSDL_STUDY = 'ws/study/v1/studyWsdl.wsdl';
	const WSDL_SED = 'ws/studyEventDefinition/v1/studyEventDefinitionWsdl.wsdl';
	const WSDL_DATA = 'ws/data/v1/dataWsdl.wsdl';
	const WSDL_EVENT = 'ws/event/v1/eventWsdl.wsdl';
	const WSDL_SSUBJ = 'ws/studySubject/v1/studySubjectWsdl.wsdl';
	const NS_OCV1 = 'http://openclinica.org/ws/study/v1';
	const NS_OCBEANS = 'http://openclinica.org/ws/beans';
	const NS_ODM = 'http://www.cdisc.org/ns/odm/v1.3';
	
	// Set class properties
	public function __construct($ocWsInstanceURL, $ocUserName, $ocPassword) {
		$this->ocWsInstanceURL = $ocWsInstanceURL;
		$this->ocUserName = $ocUserName;
		$this->ocPassword = $ocPassword;
	}
	
	private function callSoapClient($ocWsdlLocation, $ocSoapFunction, $ocSoapArguments) {
		// trace must be on so that __getLastResponse can be used,
		// since the SoapClient library doesn't correctly parse complex responses
		$ocSoapClient = new SoapClient ( $ocWsdlLocation, array('trace'=>1));
		$ocSoapClientHeader = new WSSESecurityHeader ( $this->ocUserName, $this->ocPassword );
		$ocSoapClient->__setSoapHeaders ( $ocSoapClientHeader );
		try {
			$ocSoapClient->__soapCall($ocSoapFunction,array($ocSoapArguments));
			$response = simplexml_load_string($ocSoapClient->__getLastResponse());
			$response->registerXPathNamespace('v1', self::NS_OCV1);
			$response->registerXPathNamespace('odm', self::NS_ODM);
			return $response;
		} catch ( SoapFault $soapfault ) {
			echo "soapfault: " . $soapfault;
		}
	}
	// query that returns result then studies node with details of studies/sites to which the user has access
	public function studyListAll() {
		$ocWsdlLocation = $this->ocWsInstanceURL . self::WSDL_STUDY;
		$ocSoapFunction = 'listAll';
		$ocSoapArguments = 'listAllRequest';
		$response = $this->callSoapClient ( $ocWsdlLocation, $ocSoapFunction, $ocSoapArguments);
		return $response;
	}
	// query that returns result then odm node with the requested study metadata
	public function studyGetMetadata($ocUniqueProtocolId) {
		$ocWsdlLocation = $this->ocWsInstanceURL . self::WSDL_STUDY;
		$ocSoapFunction = 'getMetadata';
		$ocSoapArgIdentifier = new SoapVar ( $ocUniqueProtocolId, XSD_STRING, null, null, 'identifier', self::NS_OCBEANS );
		$ocSoapArgStudyRef = new SoapVar ( array ($ocSoapArgIdentifier), SOAP_ENC_OBJECT, null, null, 'studyRef', self::NS_OCBEANS );
		$ocSoapArgStudyMeta = new SoapVar ( $ocSoapArgStudyRef, SOAP_ENC_OBJECT, null, self::NS_OCV1, 'studyMetadata', self::NS_OCV1 );
		$ocSoapArguments = new SoapVar ( array ($ocSoapArgStudyMeta), SOAP_ENC_OBJECT );
        $response = $this->callSoapClient($ocWsdlLocation, $ocSoapFunction, $ocSoapArguments);
        return $response;
	}
	// inserts subject to specified study/site and returns result
	public function createSubject($ocStudySubjectId, $ocSecondaryLabel, $ocEnrollmentDate, $ocGender, $ocDateOfBirth, $ocSiteRef){
		$ocWsdlLocation = $this->ocWsInstanceURL . self::WSDL_SSUBJ;
		$ocSoapFunction = 'create';
		$ocSoapArguments = '';
	}
	// query that returns result then studySubjects node with the details for subjects at the requested study/site
	public function createSubject($ocUniqueProtocolId){
		$ocWsdlLocation = $this->ocWsInstanceURL . self::WSDL_SSUBJ;
		$ocSoapFunction = 'listAllByStudy';
		$ocSoapArguments = '';
	}
}

// variables for testing that would otherwise be passed in by the application
$ocUserName = "lstevens";
$ocPassword = "";
$ocWsInstanceURL = "https://localhost:8443/OpenClinica3141-ws/";
$ocUniqueProtocolId = "VHCRP1001";
$ocStudySubjectId = '';
$ocSecondaryLabel = '';
$ocEnrollmentDate = '';
$ocGender = '';
$ocDateOfBirth = '';
$ocSiteRef = '';

// 
$test = new OpenClinicaSoapWebService ( $ocWsInstanceURL, $ocUserName, $ocPassword );
$listall = $test->studyListAll();
$getMetadata = $test->studyGetMetadata ( $ocUniqueProtocolId );

echo "start";
//echo $listall->xpath('//v1:result')[0];
foreach ($listall->xpath('//v1:name') as $study_name){
	echo '<p>' . $study_name . '</p>';
}
echo "done";
?>