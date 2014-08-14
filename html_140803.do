set more off
set matsize 11000
cd "d:\milife"

global path "d:\milife"
global histocolor graphregion(lcolor(white) lwidth(thick) fcolor(white)) ///
	plotregion(fcolor("247 247 247")) plotregion(margin(medium)) ///
 	fcolor("163 194 255") fintensity(100) lcolor("163 194 255") lwidth(none) normopts(lcolor(orange_red)) ///
	yscale(noline) ylabel(#4, grid glwidth(medthick) glcolor(white)) ymtick(##2, noticks grid glwidth(vvvthin) glcolor(white)) ///
	xscale(noline) xlabel(#4, grid glwidth(medthick) glcolor(white)) xmtick(##2, noticks grid glwidth(vvvthin) glcolor(white)) 
	
global piecolor /*missing*/ angle(0) plabel(_all name, gap(10)) line(lcolor(white)) intensity(inten30) legend(region(lcolor(white))) ///
	graphregion(fcolor(white) lcolor(white) lwidth(none))

do "$path\html_data_dictionary\syntax\page_headers.do"

***********************child baseline****************************************************
cd "$path\html_data_dictionary\childbl"

use "$path\childbl\ChildBLwrkMar17.2013.dta", clear
drop ctimestmp
compress

***** drop variables with all values missing or no variation
unab 1lst: *
foreach y of local 1lst {
	*di "`y'"
	egen m=total(missing(`y'))
	*quietly: inspect `y'
	quietly: tab `y'
	*di "`y'" "==" r(r)
	if m==_N | r(r)==1 {
		drop `y' 
		di "`y'"
	}
	else{
		local r`y'=r(r)
		di `r`y''
	}
	drop m
}
unab alst: *
unab idlst: *id* *ID*
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
macro drop _1lst _alst _idlst _vlst 

*macro list _all

**** create html for all str variables. 
capture htclose
htopen using childblstr, replace
htput <link rel=stylesheet href="..\R2HTMLa.css" type=text/css>
htput <body style="margin-top: 0; margin-bottom: 5px">
htput <a NAME="top"></a>
htput $childblstr_header
htput <table cellspacing=0 border=1><tr><td><table border="0" cellpadding="4" cellspacing="2">
htput <tr class=firstline><td>String Variable Names</td><td>Variable Labels</td></tr>
foreach y of local svlst {
	*di "`y'"
	htput <tr><td><a NAME="l`y'"></a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="#`y'"><b>`y'</b></a> </td><td> `: di " `: var label `y' ' " ' </td></tr>
}
htput </table></td></tr></table><br>

foreach y of local svlst {
	*di "`y'"
	htput <hr><h4> Descriptive Analysis of Variable: <a NAME="`y'"></a><span class="vname"> `y' </span></h4>
	htput <h4> Label: `: di " `: var label `y' ' " '</h4>
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
htopen using childbl, replace
htput <link rel=stylesheet href="..\R2HTMLa.css" type=text/css>
htput <body style="margin-top: 0; margin-bottom: 5px">
htput <a NAME="top"></a>
htput $childbl_header
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


***********************parent baseline****************************************************
cd "$path\html_data_dictionary\parbl"

use "$path\parbl\ParBLMom&DadCleanmergeMar17.2013.dta", clear
*drop ctimestmp
drop pmontot
compress

***** drop variables with all values missing or no variation
unab 1lst: *
foreach y of local 1lst {
	*di "`y'"
	egen m=total(missing(`y'))
	*quietly: inspect `y'
	quietly: tab `y'
	*di "`y'" "==" r(r)
	if m==_N | r(r)==1 {
		drop `y' 
		di "`y'"
	}
	else{
		local r`y'=r(r)
		di `r`y''
	}
	drop m
}
unab alst: *
unab idlst: *id* //*ID*
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
macro drop _1lst _alst _idlst _vlst 

*macro list _all

**** create html for all str variables. 
capture htclose
htopen using parblstr, replace
htput <link rel=stylesheet href="..\R2HTMLa.css" type=text/css>
htput <body style="margin-top: 0; margin-bottom: 5px">
htput <a NAME="top"></a>
htput $parblstr_header
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
htopen using parbl, replace
htput <link rel=stylesheet href="..\R2HTMLa.css" type=text/css>
htput <body style="margin-top: 0; margin-bottom: 5px">
htput <a NAME="top"></a>
htput $parbl_header
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
		htsummaryv `y', head freq format(%12.0g) missing rowtotal close
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


***********************child follow up****************************************************
cd "$path\html_data_dictionary\childfu"

use "$path\ChildFlwUp\CFUclean6.3.2013.dta", clear
*drop ctimestmp
compress

***** drop variables with all values missing or no variation
unab 1lst: *
foreach y of local 1lst {
	*di "`y'"
	egen m=total(missing(`y'))
	*quietly: inspect `y'
	quietly: tab `y'
	*di "`y'" "==" r(r)
	if m==_N | r(r)==1 {
		drop `y' 
		di "`y'"
	}
	else{
		local r`y'=r(r)
		di `r`y''
	}
	drop m
}
unab alst: *
unab idlst: *id* *ID*
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
macro drop _1lst _alst _idlst _vlst 

*macro list _all

**** create html for all str variables. 
capture htclose
htopen using childfustr, replace
htput <link rel=stylesheet href="..\R2HTMLa.css" type=text/css>
htput <body style="margin-top: 0; margin-bottom: 5px">
htput <a NAME="top"></a>
htput $childfustr_header
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
htopen using childfu, replace
htput <link rel=stylesheet href="..\R2HTMLa.css" type=text/css>
htput <body style="margin-top: 0; margin-bottom: 5px">
htput <a NAME="top"></a>
htput $childfu_header
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

***********************genotype****************************************************
cd "$path\html_data_dictionary\geno"

use "$path\Gdata\miLifebioSalivadata.dta", clear
*drop ctimestmp
compress

***** drop variables with all values missing or no variation
unab 1lst: *
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
unab alst: *
unab idlst: *id* *ID*
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
macro drop _1lst _alst _idlst _vlst 

*macro list _all

**** create html for all str variables. 
capture htclose
htopen using geno, replace
htput <link rel=stylesheet href="..\R2HTMLa.css" type=text/css>
htput <body style="margin-top: 0; margin-bottom: 5px">
htput <a NAME="top"></a>
htput $geno_header
htput <table cellspacing=0 border=1><tr><td><table border="0" cellpadding="4" cellspacing="2">
htput <tr class=firstline><td>String Variable Names</td><td>Variable Labels</td></tr>
foreach y of local svlst {
	*di "`y'"
	htput <tr><td><a NAME="l`y'"></a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="#`y'"><b>`y'</b></a> </td><td> `: di " `: var label `y' ' " ' </td></tr>
}
htput </table></td></tr></table><br>

htput <table cellspacing=0 border=1><tr><td><table border="0" cellpadding="4" cellspacing="2">
htput <tr class=firstline><td>Numeric Variable Names</td><td>Variable Labels</td></tr>
foreach y of local nvlst {
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
	htput <br><a href="#l`y'"><b>Back to List</b></a><br>
}

foreach y of local nvlst {
	di "`y'"
	htput <hr><h4> Variable Name: <a NAME="`y'"></a><span class="vname"> `y' </span></h4>
	htput <h4> Variable Label: `: di " `: var label `y' ' " '</h4>
	lab var `y' "`y'"
	if `r`y''<10 {
		htsummaryv `y', head freq format(%8.2f) missing rowtotal close
		graph pie, over(`y') $piecolor
	}
	else {
		htsummaryv `y', head format(%8.2f) test close
		histogram `y', freq norm title("Histogram") xtitle("`y'") ytitle("Frequency, # of Respondents") $histocolor
	}
	graph export "img/`y'.png", replace
	htput <img src="img/`y'.png">
	htput <br><a href="#l`y'"><b>Back to List</b></a><br>
}
htclose

