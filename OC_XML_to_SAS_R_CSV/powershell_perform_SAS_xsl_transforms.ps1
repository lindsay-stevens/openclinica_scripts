param([string[]]$ocextract, [string[]]$mapxsl, [string[]]$mapout, [string[]]$dataxsl, [string[]]$dataout, [string[]]$formatxsl, [string[]]$formatout)
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
$xslt.Load("$mapxsl");
$xslt.Transform("$ocextract", "$mapout");
$xslt.Load("$dataxsl");
$xslt.Transform("$ocextract", "$dataout");
$xslt.Load("$formatxsl");
$xslt.Transform("$ocextract", "$formatout");