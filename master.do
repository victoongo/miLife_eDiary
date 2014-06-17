set more off
*cd "Z:\Common Folder\miLife Study\"
cd "D:\milife"

* step one, merge cleaned data from various sources and collection points
/*
use "ChildBL\ChildBLwrkMar17.2013.dta", clear
merge 1:1 id using "ParBL\ParBLMom&DadCleanmergeMar17.2013.dta", nogen 
merge 1:1 id using "ChildFlwUp\CFUclean6.3.2013.dta", nogen
merge 1:1 id using "Gdata\miLifebioSalivadata.dta", nogen
merge 1:1 id using "Demographic\sldemog_analysis.dta", nogen 
save "master_personwide", replace
merge 1:m id using "eDiarydata\milife_daywide.dta", nogen 
compress
save "eDiarydata\milife_merge", replace
*/

* add the constructed variables to the merged file for initial analysis

use "eDiarydata\milife_merge", clear 
do "constructed_victor.do"
do "constructed_mike.do"
do "constructed_victor2.do"
* create a log file function as a codebook/list of variables
log using miLifecdbk.smcl, replace
des 
log close
* 
save "master_daywide", replace

/*
use master_daywide, clear
*/
