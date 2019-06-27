param([string[]]$ocextract, [string[]]$projectpath, [string[]]$studyname)
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
$xslt.Load("xml_convert_r_dataframes_with_factors.xsl");
$xslt.Transform("$ocextract", "$projectpath" + "xml_convert_r_dataframes_out.txt");

$filecontents = (get-content ("$projectpath" + "xml_convert_r_dataframes_out.txt"))
$numlines = $filecontents.length
for($i=0;$i -lt $numlines;$i++)
{
    $linelength = $filecontents[$i].length
    for ($j=$linelength - 1;$j -ge 0;$j--){

        if ([INT][CHAR]$filecontents[$i].substring($j,1) -gt 255) {
	    $hexval = "0000" + ([convert]::tostring(([INT][CHAR]$filecontents[$i].substring($j,1) ),16))
            $hexval = $hexval.substring($hexval.length - 4,4)
            if ($j -eq $linelength - 1) {
                $filecontents[$i] = $filecontents[$i].substring(0,$j) + "\u" + $hexval
            }
            else {
                $filecontents[$i] = $filecontents[$i].substring(0,$j) + "\u" + $hexval + $filecontents[$i].substring(($j + 1),($filecontents[$i].length - ($j + 1)))
            }
        }
    }
}
$filecontents | out-file ("$projectpath" + "R_"+ "$studyname"+"_DataFrames.R") -encoding ASCII
Remove-Item "$($projectpath)xml_convert_r_dataframes_out.txt"