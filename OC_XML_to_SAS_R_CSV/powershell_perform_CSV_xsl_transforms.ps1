param([string[]]$ocextract, [string[]]$projectpath, [string[]]$studyname)
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
$xslt.Load("$projectpath" + "XmlWorkFiles\xml_convert_csv.xsl");
$xslt.Transform("$ocextract", ("$projectpath" + "XmlWorkFiles\xml_convert_csv_out.txt"));
$filecontents = (get-content ("$projectpath" + "XmlWorkFiles\xml_convert_csv_out.txt"))
$numlines = $filecontents.length
for($i=0;$i -lt $numlines;$i++)
{
if ($filecontents[$i].substring(0,10) -eq "TableName:") {
if ($startrow -gt 0) {
$filecontents[($startrow + 1)..($i-1)]|out-file ("$projectpath" + "$studyname" + "_" + $tablename  + ".csv") -encoding utf8
}
$startrow = $i
$tablename = $filecontents[$i].substring(10)
}
}
$filecontents[($startrow + 1)..($numlines-1)]|out-file ("$projectpath" + "$studyname" + "_" + $tablename  + ".csv") -encoding utf8