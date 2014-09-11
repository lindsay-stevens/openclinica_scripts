#XML Transformations
The files in this directory can be used to convert OpenClinica ODM 1.3 XML to other formats.

Powershell scripts are provided for running the transformations, but the XSLs work with other XSL processors too - for example Saxon.

Variables in the output formats are organised into sets corresponding to their item group.

Each of the xsl files refer to renaming map stylesheet [xml_convert_dynamic_lookup](xml_convert_dynamic_lookup.xsl) which lists the CRF and Item Group name combinations and what they should be renamed to in the output. If this is not used, the dataset names default to the Item Group OID.

An example OpenClinica [extract.properties](extract.properties) file is included to demonstrate how to make an XSL method available in the OpenClinica interface - extract.10. uses the xml_convert_r_dataframes_with_factors.

## CSV
In addition to running the XSL, the powershell script divides the initial output CSV into separate files per item group.

* [powershell_perform_CSV_xsl_transforms.ps1](powershell_perform_CSV_xsl_transforms.ps1)
* [xml_convert_csv.xsl](xml_convert_csv.xsl)

## R

* [powershell_perform_R_xsl_transforms.ps1](powershell_perform_R_xsl_transforms.ps1)
* [xml_convert_r_dataframes.xsl](xml_convert_r_dataframes.xsl)
* [xml_convert_r_dataframe_factors.xsl](xml_convert_r_dataframe_factors.xsl)
* [xml_convert_r_dataframes_with_factors.xsl](xml_convert_r_dataframes_with_factors.xsl) combined version of the above two xsl files - not run by powershell script

## SAS

* [powershell_perform_SAS_xsl_transforms.ps1](powershell_perform_SAS_xsl_transforms.ps1)
* [xml_convert_sas_data.xsl](xml_convert_sas_data.xsl)
* [xml_convert_sas_format.xsl](xml_convert_sas_format.xsl)
* [xml_convert_sas_map.xsl](xml_convert_sas_map.xsl)

## Access

* [xml_convert_access.xsl](xml_convert_access.xsl)
* [OCInterfaceFunctions.bas](OCInterfaceFunctions.bas) functions that prepare and send powershell commands. Requires references to:
  * Microsoft Office 14.0 Object Library
  * Microsoft Scripting Runtime
* [modRunXSLTransform.bas](modRunXSLTransform.bas) work in progress, aiming to implement the powershell functions in VBA. Requires references to:
  * Microsoft XML, v6.0
  * Microsoft Scripting Runtime

The XML transformation files now include the ability to import into MS Access.  This transformation file includes additional tables with a prefix of “study”; for example “studyitem” lists the definitions of all the fields.  Also supplied is the Access visual basic code to allow Access as to be the front end for converting the XML into SAS, R, CSV or into the Access database itself.  To implement this code, import the code as a module into the Access Database and then create a method for calling the functions (e.g. macros, buttons on a form, etc). The function names are as follows:

* GenerateSASExtract() – performs the SAS conversion
* GenerateRExtract() – performs the R conversion
* GenerateCSVExtract() – performs the CSV conversion
* ImportOCExtractAsTables() – converts the XML and then imports into Access tables.

The module has 2 constants that need to be configured:

* STUDY_NAME = "ReplaceMeWithStudyName" – this should be set to the OpenClinica study name the Access database is to be used for.
* USE_TABLENAME_CONVERTER = false – setting this to true creates a conversion table that can be used to specify how the tables created by the transformation scripts (for SAS, R, CSV and Access) should be named.  The TableName column in this table specifies the name to use for a specified CRF name and itemgroup name.  Running the ImportOCExtractAsTables() with this constant set to true will prepopulate the conversion table with the records required if the table is not already populated.

The last set up required for the Access front end is to place all the xml transformation and powershell scripts into a sub-folder named XmlWorkFiles.