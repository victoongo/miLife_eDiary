***********************parent baseline****************************************************
cd "$path\html_data_dictionary\daily"

use "$path\eDiarydata\milife_merge", clear
unab olst: *

use "$path\master_daywide.dta", clear
compress
unab alst: *
local clst: list alst - olst
di "`clst'"
keep `clst'
macro drop _alst _olst _clst 

local survey childblcon parblcon amcon ascon pmcon dailycon personmean supportvar
run "$path\varcon_list.do"
local childblcon_dir childbl
local parblcon_dir parbl
local amcon_dir daily
local ascon_dir daily
local pmcon_dir daily
local dailycon_dir daily
local personmean_dir daily
local supportvar_dir daily
foreach pre of local survey {
	***** drop variables with all values missing or no variation
	cd "$path\html_data_dictionary/``pre'_dir'"
	di "`pre'" 
	di "$`pre'"
	
	**** create html for all num variables. 
	capture htclose
	htopen using `pre', replace
	htput <link rel=stylesheet href="..\R2HTMLa.css" type=text/css>
	htput <body style="margin-top: 0; margin-bottom: 5px">
	htput <a NAME="top"></a>
	htput $`pre'_header
	htput <table cellspacing=0 border=1><tr><td><table border="0" cellpadding="4" cellspacing="2">
	htput <tr class=firstline><td>Numeric Variable Names</td><td>Variable Labels</td></tr>
	foreach y of global `pre' {
		di "`y'"
		htput <tr><td><a NAME="l`y'"></a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="#`y'"><b>`y'</b></a> </td><td> `: di " `: var label `y' ' " ' </td></tr>
	}
	htput </table></td></tr></table><br>

	foreach y of global `pre' {
		di "`y'"
		htput <hr><h4> Variable Name: <a NAME="`y'"></a><span class="vname"> `y' </span></h4>
		htput <h4> Variable Label: `: di " `: var label `y' ' " '</h4>
		ds `y', has(type double float)
		local numlst "`r(varlist)'" 
		lab var `y' "`y'"
		quietly: tab `y'
		local r`y'=r(r)
		if "`numlst'"~="" | `r`y''>=10 {
			htsummaryv `y', head format(%8.2f) test close
			histogram `y', freq norm title("Histogram") xtitle("`y'") ytitle("Frequency, # of Respondents") $histocolor
		}
		else {
			*format `y' %8.2f
			*recast float `y', force
			htsummaryv `y', head freq format(%8.2f) missing rowtotal close
			graph pie, over(`y') $piecolor
		}
		graph export "img/`y'.png", replace
		htput <img src="img/`y'.png">
		htput <br><a href="#l`y'"><b>Back to List</b></a><br>
	}
	htclose
}

