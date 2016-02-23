# Discrepancy Notes PDF Report
This project is an XSLT script that converts an ODM XML "Full" extract file to 
a discrepancy notes report PDF. The styling is very basic, with each discrepancy 
note and it's related data in a large table. Mostly one per page.

Look in the "example" folder for an example input and output, using the script.

The script was tested using OpenClinica 3.1.4.1 and 3.7.


## Manual Usage
How to run the script as a manual, ad-hoc task.
- Run a ODM 1.3 Full extensions extract in OpenClinica.
- Copy the file to the same folder as the XSL file.
- Rename the extracted file 'extract.xml'.
- Run the 'run.bat' file.
- A PDF will be created in the current directory.


## Usage via OpenClinica
How to add the script as an extract option in the OpenClinica extract UI.
- Copy the "discrepancy_notes_report_pdf.xsl" to the installation's data folder, 
  at "tomcat/openclinica.data/xslt".
- Add the following configuration to installation's "extract.properties" file.
  Be sure to update "extract.11" and "pdf11" if these extract option numbers 
  are already in use.
  + In early OC versions, it is in "WEB-INF/classes/extract.properties".
  + In recent OC versions, it is in "tomcat/openclinica.config".

```ini
extract.11.odmType=full
extract.11.file=xml_convert_dnotes_pdf.xsl
extract.11.fileDescription=Discrepancy Notes PDF
extract.11.linkText=Run Now
extract.11.helpText=Discrepancy Notes PDF
extract.11.location=$exportFilePath/$datasetName/dnotes_pdf
extract.11.exportname=dnotes_pdf_$datasetName_$dateTime.xml
extract.11.success=The extract completed successfully. The file is available for down load $linkURL.
extract.11.post=pdf11
pdf11.postProcessor=pdf
pdf11.location=$exportFilePath/$datasetName/dnotes_pdf
pdf11.exportname=dnotes_pdf_$datasetName_$dateTime.xml
pdf11.deleteOld=true
pdf11.zip=true
```

- Restart tomcat (or redeploy the OpenClinica app) so that the new configuration 
  in extract.properties is read.


## Known Issues
The following may or may not be a problem for you.
- It is assumed that all subjects are assigned to sites, not the main study.
- Item value label lookups are done for single select items but not multi select.
- Only discrepancy notes with 'New' or 'Updated' status are included.
- The ODM XML extract does not output ItemData where the value is blank. This 
  means that the quantity of Discrepancy Notes in the PDF report might be 
  different to what is reported in the UI, if there are notes on blank items.
- When running the script on the command line, there may be some messages about 
  fonts being replaced; this is an issue with Xalan / the jar resources, not the 
  script.
