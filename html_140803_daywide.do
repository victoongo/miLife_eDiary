
***********************day wide****************************************************
cd "$path\html_data_dictionary\daily"
use "$path\milife_daywide.dta", clear
compress

local survey am as pm
foreach pre of local survey {
	***** drop variables with all values missing or no variation
	drop zdmaxnqperssn`pre'
	unab 1lst: `pre'* *`pre'
	foreach y of local 1lst {
		*di "`y'"
		egen m=total(missing(`y'))
		*quietly: inspect `y'
		quietly: tab `y'
		*di "`y'" "==" r(r)
		if m==_N { //| r(r)==1 {
			drop `y' 
			di "`y'"
		}
		else{
			local r`y'=r(r)
			di `r`y''
		}
		drop m
	}
	** this will drop 5 vars that has very low response rate and all the responses are "No"

	unab alst: `pre'* *`pre'
	unab idlst: *id*
	local vlst: list alst - idlst
	di "`vlst'"

	ds `vlst', has(type string)
	*di "`r(varlist)'"
	local svlst "`r(varlist)'"
	local nvlst: list vlst - svlst
	*local v2lst `svlst' `nvlst'
	di "`svlst'"
	di "`nvlst'"
	*di "`v2lst'"
	macro drop _1lst _vlst _alst _idlst 
/*
	local sv2lst
	foreach y of local svlst {
		if `r`y''>50 {
			local sv2lst `sv2lst' `y'
		}
	}
	local svlst: list svlst - sv2lst
*/
	*macro list _all
	
	**** create html for all str variables. 
	capture htclose
	htopen using `pre'str, replace
	htput <link rel=stylesheet href="..\R2HTMLa.css" type=text/css>
	htput <body style="margin-top: 0; margin-bottom: 5px">
	htput <a NAME="top"></a>
	htput $`pre'str_header
	htput <table cellspacing=0 border=1><tr><td><table border="0" cellpadding="4" cellspacing="2">
	htput <tr class=firstline><td>String Variable Names</td><td>Variable Labels</td></tr>
	foreach y of local svlst {
		*di "`y'"
		htput <tr><td><a NAME="l`y'"></a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="#`y'"><b>`y'</b></a> </td><td> `: di " `: var label `y' ' " ' </td></tr>
	}
	htput </table></td></tr></table><br>

	foreach y of local svlst {
		*di "`y'"
		htput <hr><h4> Variable Name: <a NAME="`y'"></a><span class="vname"> `y' </span></h4>
		htput <h4> Variable Label: `: di " `: var label `y' ' " '</h4>
		lab var `y' "`y'"
		replace `y'=subinstr(`y', "`", "", .)
		htsummaryv `y', head freq method(string) missing rowtotal close
		*htlog tab `y'
		/*if `r`y''<10 {
			graph piev, over(`y') missing pl(_all name, color(gs12) gap(10)) legend(on)
			**histogram `y', freq fi(inten0) lw(vvthin) xtitle("`y'") ytitle("Frequency, # of Responding Residents")
			graph export img\`y'.png, replace
			htput <img src="img\`y'.png">
		}*/
		htput <br><a href="#l`y'"><b>Back to List</b></a><br>
	}
	htclose

	**** create html for all num variables. 
	capture htclose
	htopen using `pre', replace
	htput <link rel=stylesheet href="..\R2HTMLa.css" type=text/css>
	htput <body style="margin-top: 0; margin-bottom: 5px">
	htput <a NAME="top"></a>
	htput $`pre'_header
	htput <table cellspacing=0 border=1><tr><td><table border="0" cellpadding="4" cellspacing="2">
	htput <tr class=firstline><td>Numeric Variable Names</td><td>Variable Labels</td></tr>
	foreach y of local nvlst {
		*di "`y'"
		htput <tr><td><a NAME="l`y'"></a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="#`y'"><b>`y'</b></a> </td><td> `: di " `: var label `y' ' " ' </td></tr>
	}
	htput </table></td></tr></table><br>

	foreach y of local nvlst {
		di "`y'"
		htput <hr><h4> Variable Name: <a NAME="`y'"></a><span class="vname"> `y' </span></h4>
		htput <h4> Variable Label: `: di " `: var label `y' ' " '</h4>
		lab var `y' "`y'"
		if `r`y''<10 {
			htsummaryv `y', head freq format(%8.2f) missing rowtotal close
			*graph pie, over(`y') $piecolor
		}
		else {
			htsummaryv `y', head format(%8.2f) test close
			*histogram `y', freq norm title("Histogram") xtitle("`y'") ytitle("Frequency, # of Respondents") $histocolor
		}
		*graph export "img/`y'.png", replace
		htput <img src="img/`y'.png">
		htput <br><a href="#l`y'"><b>Back to List</b></a><br>
	}
	htclose
/*	
	**** create html for non-long-text variables. 
	capture htclose
	htopen using daywide, replace
	htput <link rel=stylesheet href="R2HTMLa.css" type=text/css>
	htput <a NAME="top"></a>
	htput <table cellspacing=0 border=1><td><table border="0" cellpadding="4" cellspacing="2">
	htput <tr class=firstline><td>String Variable Names</td><td>Varible Labels (list of string variables with less than 50 unique values)</td></tr>
	foreach y of local svlst {
		di "`y'"
		htput <tr><td><a NAME="l`y'"></a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="#`y'">`y'</a> </td><td> `: di " `: var label `y' ' " ' </td></tr>
	}
	htput <tr class=firstline><td>Numeric Variable Names</td><td>Varible Labels</td></tr>
	foreach y of local nvlst {
		di "`y'"
		htput <tr><td><a NAME="l`y'"></a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="#`y'">`y'</a> </td><td> `: di " `: var label `y' ' " ' </td></tr>
	}
	htput </table></td></table><br>

	foreach y of local svlst {
		htput <hr><h4> Descriptive Analysis of Variable: <a NAME="`y'"></a>{ `y' }</h4>
		htput <h4> Label: `: di " `: var label `y' ' " '</h4>
		lab var `y' "`y'"
		replace `y'=subinstr(`y', "`", "", .)
		htsummary `y', head freq method(string) missing rowtotal close
		/*if `r`y''<10 {
			graph pie, over(`y') missing pl(_all name, color(gs12) gap(10)) legend(on)
			**histogram `y', freq fi(inten0) lw(vvthin) xtitle("`y'") ytitle("Frequency, # of Responding Residents")
			graph export img\`y'.png, replace
			htput <img src="img\`y'.png">
		}*/
		htput <br><a href="#l`y'"><b>Back to List</b></a><br>
	}
	foreach y of local nvlst {
		htput <hr><h4> Descriptive Analysis of Variable: <a NAME="`y'"></a>{ `y' }</h4>
		htput <h4> Label: `: di " `: var label `y' ' " '</h4>
		lab var `y' "`y'"
		if `r`y''<10 {
			htsummary `y', head freq format(%8.2f) missing rowtotal close
			*graph pie, over(`y') missing pl(_all name, color(gs12) gap(10)) legend(on)
		}
		else {
			htsummary `y', head format(%8.2f) test close
			*histogram `y', freq norm fi(inten0) lw(vvthin) title("Histogram") xtitle("`y'") ytitle("Frequency, # of Person-days")
		}
		*graph export img\`y'.png, replace
		htput <br><img src="img\`y'.png">
		htput <br><a href="#l`y'"><b>Back to List</b></a><br>
	}
	htclose
*/
/*
	**** create html for long-text variables. 
	** the tab command only allow a limited string length display
	capture htclose
	htopen using daywidelongtext, replace
	htput <link rel=stylesheet href="R2HTMLa.css" type=text/css>
	htput <a NAME="top"></a>
	htput <table cellspacing=0 border=1><td><table border="0" cellpadding="4" cellspacing="2">
	htput <tr class=firstline><td>String Variable Names</td><td>Varible Labels (list of string variables with more than 50 unique values)</td></tr>
	foreach y of local sv2lst {
		di "`y'"
		htput <tr><td><a NAME="l`y'"></a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="#`y'">`y'</a> </td><td> `: di " `: var label `y' ' " ' </td></tr>
	}
	htput </table></td></table><br>
	foreach y of local sv2lst {
		htput <hr><h4> Descriptive Analysis of Variable: <a NAME="`y'"></a>{ `y' }</h4>
		htput <h4> Label: `: di " `: var label `y' ' " '</h4>
		lab var `y' "`y'"
		replace `y'=subinstr(`y', "`", "", .)
		htlog tab `y'
		htput <br><a href="#l`y'"><b>Back to List</b></a><br>
	}
	htclose
*/

}

