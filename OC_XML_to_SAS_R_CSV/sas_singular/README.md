# Introduction
SAS singular. This is a rewrite of the XSL files in the parent directory, with 
the following differences:
- All in one XSL, with 3 result-documents instead of 3 scripts -> 1 out each.
- Uses the item's SASFieldName instead of Name to ensure valid SAS column names.
- Does not use the "dynamic_lookup" script, which is for post-hoc / 
  study-specific renaming item groups and setting a study name alias.
- Hopefully more maintainable: uses elements for everything so that the XSL can 
  be pretty-printed without ruining the output, and has lots of comments.


# Usage

- Place all files in same folder
- Name ODM 1.3 Full extensions extract as 'extract.xml'
- Make sure java is on your system PATH, or change "run.bat" to point to jre\java.exe.
- Run the 'run.bat' file
- Output is an xml file with the data, a mapping file, and a SAS (9.3) script.
- Run the SAS script. The datasets you can open are in the WORK library.
  + For some reason SAS won't allow opening from the study lib.


# Features

- Item groups as data sets.
- Items named using SASFieldName.
- Items have their data types applied.
- Single select (or radio) items have their code list value labels applied.
- No explicit handling for multi-valued items, so it might break :(


# Notes

- See example folder for expected output when running using the example 
  "extract.xml" dataset.
- It should be possible to configure this XSL as an extract method by updating 
  the OpenClinica extract.properties, so that users can directly download a zip 
  containing the 3 output files instead of running this XSL after download.
