# Say you prefer to author OpenClinica CRFs in Excel 2003 XML spreadsheets,
# since it's format that can still do normal spreadsheet stuff, but is a plain 
# text format and is therefore able to be meaningfully tracked in Git. 
# However, OpenClinica requires that CRFs are uploaded in Excel 2003 XLS format.
# This script recurses through a directory to:
# 1. Remove existing .XLS files,
# 2. Open any .XML files in Excel and save them as .XLS.


# Move into the folder with the CRF definitions.
$FormsDir = "C:\Users\Lstevens\Documents\repos\1302_stopc\openclinica_study\forms"
cd $FormsDir


# Remove all existing XLS files.
Remove-Item * -Recurse -Include *.xls


# Locate all XML files and process each one.
Get-ChildItem *.xml -Recurse | ForEach-Object ($_) {

    # Make a new file name with extension "xml" instead of "xls", write it to console.
    $NewFile = $_.fullname.Substring(0,$_.fullname.Length-3) + "xls"
    Write-Host $NewFile

    # Make a new Excel object, open the XML file, save it as XLS.
    $excel = New-Object -ComObject Excel.Application
    $workbook = $excel.Workbooks.Open($_.fullname)
    $workbook.SaveAs($NewFile, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlExcel8)

    # Clean up the Excel object.
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
    Remove-Variable excel
}
