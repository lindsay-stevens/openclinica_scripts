# Introduction
R with factors. This is a rewrite of the XSL files in the parent directory, with 
the following differences:
- Question labels applied to all variables
- All metadata available, including year of birth even and crf level data
- When excluded from the export definition, variables will not appear as empty columns

# Usage
- Place all files in same folder
- Name ODM 1.3 Full extensions extract as 'extract.xml' or use Clinical data, both should work
- Run the 'run.bat' file or the transform_r.ps1 powershell script
- Output is one R file
- Run the R file using `source(<filename>)`


# Features
- Item groups as dataframes.
- All metadata available.
- Question labels and code list names applied
- Single select (or radio) items have a variable with f. prefix for their code list value labels.
- No explicit handling for multi-select items, so it might break :(


# Notes
- See example folder for expected output when running using the example 
  "extract.xml" dataset.
- It is possible to configure this XSL as an extract method by updating the 
  OpenClinica extract.properties, so that users can directly download a zip 
  containing the output files instead of running this XSL after download. See
  example below:

```ini
--------------------------
extract.10.odmType=clinical_data
extract.10.file=xml_convert_r_dataframes_with_factors.xsl
extract.10.fileDescription=R dataframe with label factors
extract.10.linkText=Run Now
extract.10.helpText=R dataframe with label factors
extract.10.location=$exportFilePath/$datasetName/R
extract.10.exportname=r_$datasetName_$dateTime.r
extract.10.zipName=r_$datasetName_$dateTime.r
#extract.10.zip=true
#extract.10.deleteOld=true
extract.10.success=Your extract job completed successfully. The file is available for download $linkURL.
#extract.10.failure=The extract did not complete due to errors. Please contact your system administrator for details.
--------------------------
```