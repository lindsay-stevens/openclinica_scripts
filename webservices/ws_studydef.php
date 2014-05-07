
<?php

// Class for adding WSSE Security Header
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
function soap_call($soap_meta, $soap_func, $soap_args) {
	$client = new SoapClient ( $soap_meta ['OCWSDL'], array (
			'trace' => 1 
	) );
	$WSSE_SH = new WSSESecurityHeader ( $soap_meta ['WSSEUSER'], $soap_meta ['WSSEPASS'] );
	
	$client->__setSoapHeaders ( $WSSE_SH );
	try {
		$client->__soapCall ( $soap_func, array (
				$soap_args 
		) );
		return $client->__getLastResponse ();
	} catch ( SoapFault $errmsg ) {
		echo "SOAP FAULT:\n" . $errmsg . "\n\n";
		echo "LAST REQUEST:\n" . htmlentities ( $client->__getLastRequest () ) . "\n";
	}
}

$soap_meta ['WSSEUSER'] = "lstevens";
$soap_meta ['WSSEPASS'] = "fb6aa5c2f5f14a5d453d2cab054b4e74ccafe8e7";
$soap_meta ['OCWSDL'] = "https://localhost:8443/OpenClinica3141-ws/ws/study/v1/studyWsdl.wsdl";

/* This set is all that is needed for the listAll function
* $soap_func = "listAll";
* $soap_args = "listAllRequest";
* print_r ( json_encode ( soap_call ( $soap_meta, $soap_func, $soap_args ) ) );
*/

// The following is required for the more complicated getMetadata function
// First, create the request which is a nested string stating the identifier to getMetadata for
$sarg_NS_v1 = "http://openclinica.org/ws/study/v1";
$sarg_NS_beans = "http://openclinica.org/ws/beans";
$sarg_identifier = new SoapVar ( "VHCRP0902", XSD_STRING, null, null, "identifier", $sarg_NS_beans );
$sarg_studyRef = new SoapVar ( array (
		$sarg_identifier 
), SOAP_ENC_OBJECT, null, null, "studyRef", $sarg_NS_beans );
$sarg_studyMetadata = new SoapVar ( $sarg_studyRef, SOAP_ENC_OBJECT, null, $sarg_NS_v1, "studyMetadata", $sarg_NS_v1 );
$sarg_final = new SoapVar ( array (
		$sarg_studyMetadata 
), SOAP_ENC_OBJECT );

$soap_func = "getMetadata";
$soap_args = $sarg_final;

$response = soap_call ( $soap_meta, $soap_func, $soap_args );
$xml_res = simplexml_load_string ( $response );

echo "completed soap_call.\n";

// With the returned info, parse it. 
// Have to declare namespaces in the simplexmlelement before you can use xpath expressions on it
// The xpath result is a simple array so it has to be picked with an index or in a loop
$ns_v1 = "http://openclinica.org/ws/study/v1";
$ns_odm = "http://www.cdisc.org/ns/odm/v1.3";

$xml_res->registerXPathNamespace('v1', $ns_v1);

$xml_result_xpath = $xml_res->xpath("//v1:result");
echo "Result: " . $xml_result_xpath[0] . "\n";

$xml_odm_xpath = $xml_res->xpath("//v1:odm");

$xml_odm = simplexml_load_string($xml_odm_xpath[0]);
$xml_odm->registerXPathNamespace('odm', $ns_odm);
foreach ($xml_odm->xpath("//odm:StudyEventRef/@StudyEventOID") as $se_oids)
{
	echo $se_oids . "\n";
}

?>