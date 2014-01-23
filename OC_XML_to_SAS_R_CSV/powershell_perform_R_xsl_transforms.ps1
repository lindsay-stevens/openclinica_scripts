param([string[]]$ocextract, [string[]]$dataframesxsl, [string[]]$dataframesout, [string[]]$dataframefactorsxsl, [string[]]$dataframefactorsout)
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
$xslt.Load("$dataframesxsl");
$xslt.Transform("$ocextract", "$dataframesout");
$xslt.Load("$dataframefactorsxsl");
$xslt.Transform("$ocextract", "$dataframefactorsout");