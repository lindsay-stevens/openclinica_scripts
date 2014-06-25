/* copy this file in the directory with the xlsx files and run it */
/* stata will create a subdirectory "dta" and put the files in there */
local dirname : pwd
local xlsxfilelist : dir . files "*.xlsx"
mkdir dta
foreach xlsxfile of local xlsxfilelist {
  local xlsxname : subinstr local xlsxfile ".xlsx" ""
  import excel using "`dirname'/`xlsxfile'", firstrow clear
  saveold "`dirname'/dta/`xlsxname'.dta" 
}

