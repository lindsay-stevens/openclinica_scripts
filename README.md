# Readme


## Introduction
This repository is a collection of miscellaneous scripts, most of which are in some way related to the [OpenClinica EDC](https://github.com/OpenClinica/OpenClinica) or clinical research data management. Many are prototypes kept for posterity which have either not been used, or have graduated to getting their own repository.


## Contents
The following is a summary of the contents of this repository, organised by language and sorted alphabetically.


### XLST
- *OC_XML_to_SAS_R_CSV*: XLST scripts for converting OpenClinica extracts in ODM 1.3 XML to CSV, R, SAS or Access. The "sas_singular" script has been adapted and included in the 3.11 release of OpenClinica.
- *collate_rules*: A XSLT script for converting rule XML files that are being worked with in Excel. In "collate" mode it groups rule assignments by target for uploading to OpenClinica. The "split" mode does the reverse.
- *compare_clinicaldata*: A XLST script for combining multiple versions of an ODM 1.3 XML file so that they can be inspected for any differences.
- *dnotes*: A XSLT script for generating a PDF report of discrepancy notes read from an OpenClinica ODM 1.3 XML file.
    - Interesting as an example of how to use XSL-FO to produce PDF documents from XML.
- *xforms*: XSLT scripts for:
    - converting an xform xml form into a flat structure for review in Excel,
    - stripping out as much non-cell-data as possible from an Excel XML 2003 spreadsheet.


### Python
- *codebook*: a simple Python script for generating CSV listing of all value-label pairs for coded items in an OpenClinica study. The input can be either an ODM 1.3 XML or study metadata XML file.
- *scrape*: a simple Python script for logging in to OpenClinica, scraping enrolment information and emailing a summary.
- *webservices*: a Python module for interacting with the OpenClinica SOAP webservices, returning OrderedDicts instead of XML. Other implementations:
    - [PHP](https://github.com/lindsay-stevens-kirby/openclinica_webservices_php)
    - [Java](https://github.com/jacobrousseau/traitocws/blob/master/TraITOCWS/src/nl/vumc/trait/oc/connect/OCWebServices.java)
    - [Python: for XForms integration](https://github.com/dimagi/openclinica-xforms/blob/master/webservices.py)
    - [Python: for a desktop client](https://github.com/toskrip/open-clinica-scripts)
- *xlsform_images*: a Python module for reading an ODK XLSForm spreadsheet an generating images of that text and/or images, to precisely control appearance. Superseded by [odk_tools](https://github.com/lindsay-stevens/odk_tools).


### Other
- *accessdatamart*: Access database and accompanying scripts for building an OpenClinica data mart. Superseded by [Community DataMart](https://github.com/lindsay-stevens/openclinica_sqldatamart).
- *crf_manager*: An Access database for managing an OpenClinica CRF library. Can read in a directory of CRF Excel ".xls" files in for review or editing, and export them ".xls" again. Can also author new CRFs in it and export them.
    - Interesting for procedures that preserve the order of rows in the spreadsheet during import and export, since the Access VBA function TransferSpreadsheet doesn't guarantee row order.
- *repeated_rules*: A VBScript with example XML templates for generating a large amount of similar rules for OpenClinica. Includes a Selenium IDE test suite definition of testing the rules, and a CRF spreadsheet that goes with the example rule XML files.
- *selenium_tasks*: Selenium IDE scripts (HTML/JavaScript) for automating OpenClinica user tasks:
    - bulk CRF version migration (now a feature of OpenClinica 3.12)
    - deleting / removing rule definitions that meet one or more filter criteria.
- *windows_script_utils*: scripts in various Windows-specific languages for miscellaneous tasks: 
    - datamart_launcher_and_backup (VBScript): launcher for Community DataMart client Access databases; checks connectivity, initiates install if necessary, and sets process-level environment variables to facilitate connections; creates a backup copy of the database before opening it.
    - excelutils (PowerShell): function to convert OpenClinica CRF templates saved as  Excel XML 2003 spreadsheets to Excel ".xls" files; function to convert Excel ".xlsx" files to CSV, one file per sheet.
    - export_access_to_excel (VBA): module for saving all non-system / temporary tables in an Access database to Excel ".xlsx". Can either export all tables as sheets in one workbook, or all tables as the only sheet in separate workbooks.
        - Interesting for an implementation of a test suite in VBA.
    - output_valid_system_paths (PowerShell): write a text file containing only valid (existing) paths present in the "PATH" user environment variable.
    - xml_file_diffs_by_folder (PowerShell): find the differences between two folder trees that have become out of sync, both in terms of whole files and content (based on file hash).

