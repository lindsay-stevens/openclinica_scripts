# Say you prefer to author OpenClinica CRFs in Excel 2003 XML spreadsheets,
# since it's format that can still do normal spreadsheet stuff, but is a plain 
# text format and is therefore able to be meaningfully tracked in Git. 
# However, OpenClinica requires that CRFs are uploaded in Excel 2003 XLS format.
# This script recurses through a directory to open any XML files in Excel and 
# save them as .XLS, overwriting if necessary.


Function Convert-XML2XLS {
    param([string] $folderPath)
    
    # Locate all XML files and process each one.
    Get-ChildItem -Path $folderPath -Include *.xml -Recurse | ForEach-Object ($_) {
    
        # Check that the XML file looks like a CRF design template.
        Try 
        {
            $xml = [System.Xml.XmlDocument](Get-Content $_.fullname)
            
            # Look for the spreadsheet name in the top of the last sheet.
            $lastSheet = $xml.Workbook.Worksheet.Count - 1
            $searchName = $xml.Workbook.Worksheet[$lastSheet].Table.Row[0].Cell.Data."#text"
            $expectedName = "OpenClinica CRF Design Template"
            $matchedName = ($searchName -eq $expectedName)
            
            # Check that the collection of sheets is as expected.
            $expectedSheets = @("CRF", "Sections", "Groups", "Items", "Instructions")
            $searchSheets = @()
            $xml.Workbook.Worksheet | foreach {$searchSheets += $_.Name}
            $matchedSheets = ((Compare-Object $expectedSheets $searchSheets).Length -eq 0)
            
            $isCRF = ($matchedName -and $matchedSheets)
        }
        Catch 
        {
            $isCRF = $False
        }
        
        # Move to the next file if this one isn't a CRF spreadsheet.
        If (!$isCRF) {Continue}
    
        # Make a new file name with extension "xml" instead of "xls", write it to console.
        $NewFile = $_.fullname.Substring(0,$_.fullname.Length-3) + "xls"
        "Writing: {0}" -f $NewFile
    
        # Make a new Excel object, open the XML file, save it as XLS.
        $excel = New-Object -ComObject Excel.Application
        $excel.DisplayAlerts = $False
        $workbook = $excel.Workbooks.Open($_.fullname)
        $workbook.SaveAs($NewFile, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlExcel8)
    
        # Clean up the Excel object.
        $excel.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
        Remove-Variable excel
        [System.GC]::Collect()
    }
}


# Alternatively, say everyone is on the XLSX train and you want to track 
# in plain text anyway. The following function will export each XLSX worksheet 
# to a separate CSV file, stored in a subfolder named "csv". Each file will take 
# the same name, followed by two underscores and the sheet name. 
# For example, "my_file.xlsx" -> "my_file__crf.csv".


Function Export-XLSX2CSV {
    param([string] $folderPath)

    Get-ChildItem -Path $folderPath -Include *.xlsx -Recurse | ForEach-Object ($_) {
        
        # Check if a "csv" subfolder exists, create it if not.
        $newFolder = Join-Path -Path $_.DirectoryName -ChildPath "csv"
        if (-not (Test-Path -Path $newFolder)) {
            New-Item -ItemType directory -Path $newFolder | Out-Null
        }

        # Make a new Excel object, open the XML file, save it as XLS.
        $excel = New-Object -ComObject Excel.Application
        $excel.DisplayAlerts = $False
        $workBook = $excel.Workbooks.Open($_.fullname)
        "Exporting CSV sheets for: {0}" -f $_.fullname
        ForEach ($workSheet in $workBook.Worksheets) {
            $newBaseName = $_.BaseName + "__" + $workSheet.Name + ".csv"
            $newFilePath = Join-Path -Path $newFolder -ChildPath $newBaseName
            $workSheet.SaveAs($newFilePath, 6)
        }

        # Clean up the Excel object.
        $excel.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
        Remove-Variable excel
        [System.GC]::Collect()
    }
}


Set-Alias -Name xml2xls -Value Convert-XML2XLS
Set-Alias -Name xlsx2csv -Value Export-XLSX2CSV
Export-ModuleMember -Alias * -Function *