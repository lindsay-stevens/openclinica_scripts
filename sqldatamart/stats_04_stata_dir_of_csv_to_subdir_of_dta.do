/* copy this file in the directory with the csv files and run it */
/* stata will create a subdirectory "dta" and put the files in there */
local dirname : pwd
local csvfilelist : dir . files "*.csv"
mkdir dta
foreach x of local csvfilelist {
  insheet using "`dirname'/`x'", comma clear
  local y : subinstr local x ".csv" ""
  saveold "`dirname'/dta/`y'.dta"
}

