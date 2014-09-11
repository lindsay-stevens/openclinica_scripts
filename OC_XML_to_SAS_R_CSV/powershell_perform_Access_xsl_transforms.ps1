param([string[]]$ocextract, [string[]]$projectpath)
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
$xslt.Load("$projectpath" + "XmlWorkFiles\xml_convert_access.xsl");
$xslt.Transform("$ocextract", "$projectpath" + "XmlWorkFiles\xml_convert_access_out.xml");