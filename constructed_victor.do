set more off
***** Child E-Diary Data *****

*CREATE A MARKER FOR THE FIRST CASE.
sort id dlocaln2
*select the first entry per child
bysort id: gen first=(_n==1)
la var first "first entry for each case"
li id dlocaln2 first in 1/100

ta id
***** counting missing for nonstring vars 
#delimit ;
global amnv aman01 aman02 aman03 aman04 amco01 amde01 amde02 amde03 amde04 amde05 amdx01 amid01
    amir01 amna01 ampa01 ampa02 ampa03 ampa04 amse01 amse02 amsq03 amsq04 amsq05 amst01;
global asnv asad01 asad02 asad03 asad04 asad05 asad06 asan01 asan02 asan03 asan04 ascd01 ascd02 
    asce01 asco03 asco05 ascu01 asde01 asde02 asde03 asde04 asde05 asdx01 asid01 asir02 asna01 asna02 
    aspa01 aspa02 aspa03 aspa04 aspm01 aspm02 aspm03 asse01 assi01 asst01 assu01 assx01 assx02 assx03 
    assx04 assx05;
global pmnv pman01 pman02 pman03 pman04 pmau01 pmau05 pmau06 pmau07 pmau08 pmau09 pmcd01 pmcd02 
    pmcd03 pmcd05 pmcd07 pmcd09 pmce01 pmco03 pmco05 pmcu01 pmcu05 pmcu06 pmcu07 pmcu08 pmcx01 pmcx02 
    pmcx03 pmcx07 pmcx08 pmde01 pmde02 pmde03 pmde04 pmde05 pmed01 pmed02 pmed03 pmed04 pmed05 pmed06 
    pmed07 pmed08 pmid01 pmij01 pmij02 pmij03 pmij04 pmir01 pmcx05 pmmu01 pmmu05 pmmu06 pmmu07 pmmu08 
    pmmu09 pmna01 pmna02 pmnx01 pmnx04 pmnx06 pmnx07 pmnx03 pmnx09 pmpa01 pmpa02 pmpa03 
    pmpa04 pmpm01 pmpm02 pmpm03 pmse01 pmss01 pmss02 pmss03 pmst01 pmsu01 pmsu02 pmsu03 pmsu04 pmsu07 
    pmsu08 pmsu1 pmtu01 pmtu03 pmtu04 pmtu05 pmtu06 pmtu07 pmtu08 pmtu09 pmtu11 pmtu12 pmtu13 pmtu14 
    pmtu15 pmtu16 pmtu17 pmtu18 pmtu19 pmtu20 pmtu21 pmtu23 pmtu24 pmws01 pmws02 pmws03 pmws04 pmwv01 
    pmwv02 pmwv03 pmwv04 pmpx02;
#delimit cr
des $amnv $asnv $pmnv
unab alst: am* as* pm*
local nlst $amnv $asnv $pmnv
local slst: list alst - nlst
des `slst'
egen amnmiss=rowmiss($amnv)
egen asnmiss=rowmiss($asnv)
egen pmnmiss=rowmiss($pmnv)
egen totnmiss=rowtotal(amnmiss asnmiss pmnmiss)
lab var amnmiss "Number of missing in am diaries"
lab var asnmiss "Number of missing in as diaries"
lab var pmnmiss "Number of missing in pm diaries"
lab var totnmiss "Number of missing in all thee diaries"
tab1 *nmiss

/*
str vars
tab1 amco02 ammi01 amsq01 amsq02 
tab1 ascd03 asco01 asco02 asco04 ascu04 asmi01 assu04 
tab1 pmau02 pmau03 pmau04 pmce02 pmce03 pmco01 pmco02 pmco04 pmcu02 pmcu03 pmcu04 
tab1 pmcx04 pmcx06 pmmi01 pmmu02 pmmu03 pmmu04 pmn08 pmnx02 pmnx05 pmnx08 pmpx01 
tab1 pmpx03 pmse02 pmse03 pmsu05 pmsu06 pmtu02 pmtu10 pmtu22 
*/

***** Scale creation, AM outcomes
* pnas anxiety subscale - am
egen amanx=rowmean(aman01 aman02 aman03 aman04)
replace amanx=amanx*4
egen amanx_miss=rowmiss(aman01 aman02 aman03 aman04)
gen amanxb=cond(amanx==0,0,cond(amanx>0 & amanx~=.,1,.))
lab var amanx_miss "number of missing am pnas anxiety questions"
lab var amanx "am pnas - anxiety"
lab var amanxb "am pnas - anxiety - binary"
tab1 amanx_miss amanx
tab amanx amanxb

* depression - am
egen amdep=rowmean(amde01 amde02 amde03 amde04 amde05)
replace amdep=amdep*5
egen amdep_miss=rowmiss(amde01 amde02 amde03 amde04 amde05)
gen amdepb=cond(amdep==0,0,cond(amdep>0 & amdep~=.,1,.))
lab var amdep_miss "number of missing am pnas depression questions"
lab var amdep "am pnas - depression"
lab var amdepb "am pnas - depression - binary"
tab1 amdep_miss amdep

* pnas positive affect subscale - am
egen ampos=rowmean(ampa01 ampa02 ampa03 ampa04)
replace ampos=ampos*4
egen ampos_miss=rowmiss(ampa01 ampa02 ampa03 ampa04)
gen amposb=cond(ampos==0,0,cond(ampos>0 & ampos~=.,1,.))
lab var ampos_miss "number of missing am pnas positive affect questions"
lab var ampos "am pnas - positive affect"
lab var amposb "am pnas - positive affect - binary"
tab1 ampos_miss ampos

***** scale creation, pm protective influence
* parental monitoring
egen aspmo=rowmean(aspm01 aspm02 aspm03)
replace aspmo=aspmo*3
egen aspmo_miss=rowmiss(aspm01 aspm02 aspm03)
gen aspmob=cond(aspmo==0,0,cond(aspmo>0 & aspmo~=.,1,.))
lab var aspmo_miss "number of missing pm parental monitoring questions"
lab var aspmo "pm parental monitoring"
lab var aspmob "pm parental monitoring - binary"
tab1 aspmo_miss aspmo
ta aspmob aspmo

***** Scale creation, AS outcomes
* pnas anxiety subscale - as
egen asanx=rowmean(asan01 asan02 asan03 asan04)
replace asanx=asanx*4
egen asanx_miss=rowmiss(asan01 asan02 asan03 asan04)
gen asanxb=cond(asanx==0,0,cond(asanx>0 & asanx~=.,1,.))
lab var asanx_miss "number of missing as pnas anxiety questions"
lab var asanx "as pnas - anxiety"
lab var asanxb "as pnas - anxiety - binary"
tab1 asanx_miss asanx
tab asanx asanxb

* depression - as
egen asdep=rowmean(asde01 asde02 asde03 asde04 asde05)
replace asdep=asdep*5
egen asdep_miss=rowmiss(asde01 asde02 asde03 asde04 asde05)
gen asdepb=cond(asdep==0,0,cond(asdep>0 & asdep~=.,1,.))
lab var asdep_miss "number of missing as pnas depression questions"
lab var asdep "as pnas - depression"
lab var asdepb "as pnas - depression - binary"
tab1 asdep_miss asdep

* pnas positive affect subscale - as
egen aspos=rowmean(aspa01 aspa02 aspa03 aspa04)
replace aspos=aspos*4
egen aspos_miss=rowmiss(aspa01 aspa02 aspa03 aspa04)
gen asposb=cond(aspos==0,0,cond(aspos>0 & aspos~=.,1,.))
lab var aspos_miss "number of missing as pnas positive affect questions"
lab var aspos "as pnas - positive affect"
lab var asposb "as pnas - positive affect - binary"
tab1 aspos_miss aspos

* adh items. 
egen asad=rowmean(asad01 asad02 asad03 asad04 asad05 asad06)
replace asad=asad*6
egen asad_miss=rowmiss(asad01 asad02 asad03 asad04 asad05 asad06)
gen asadb=cond(asad==0,0,cond(asad>0 & asad~=.,1,.))
lab var asad_miss "number of missing attention-deficit/hyperactivity questions"
lab var asad "attention-deficit/hyperactivity problems - count"
lab var asadb "attention-deficit/hyperactivity problems  - binary" 
tab1 asad_miss asad asadb

***** Scale creation, PM diary daily triggers
* Exposure to fighting at home, school, neighborhood and/or somewhere else - pm
egen pmetv=rowmean(pmwv01 pmwv02 pmwv03 pmwv04)
replace pmetv=pmetv*4
egen pmetv_miss=rowmiss(pmwv01 pmwv02 pmwv03 pmwv04)
gen pmetvb=cond(pmetv==0,0,cond(pmetv>0 & pmetv~=.,1,.))
lab var pmetv_miss "number of missing pm etv questions"
lab var pmetv "pm exposure to fighting at home school neighborhood or somewhere else"
lab var pmetvb "pm exposure to fighting at home school neighborhood or somewhere else - binary"
tab1 pmetv_miss pmetv

* exposure to substances @ home school neighborhood or somewhere else - pm
egen pmets=rowmean(pmws01 pmws02 pmws03 pmws04)
replace pmets=pmets*4
egen pmets_miss=rowmiss(pmws01 pmws02 pmws03 pmws04)
gen pmetsb=cond(pmets==0,0,cond(pmets>0 & pmets~=.,1,.))
lab var pmets_miss "number of missing pm ets questions"
lab var pmets "pm exposure to substances at home school neighborhood or somewhere else"
lab var pmetsb "pm exposure to substances at home school neighborhood or somewhere else - binary"
tab1 pmets_miss pmets

* did anything really bad or stressful happen, mean to you, cyber bullying? 
tab1 pmnx04  pmnx01 pmnx07

* anything positive happen, feel good about myself
tab1 pmpx02  

***** scale creation, pm protective influence
* parental monitoring
egen pmpmo=rowmean(pmpm01 pmpm02 pmpm03)
replace pmpmo=pmpmo*3
egen pmpmo_miss=rowmiss(pmpm01 pmpm02 pmpm03)
gen pmpmob=cond(pmpmo==0,0,cond(pmpmo>0 & pmpmo~=.,1,.))
lab var pmpmo_miss "number of missing pm parental monitoring questions"
lab var pmpmo "pm parental monitoring"
lab var pmpmob "pm parental monitoring - binary"
tab1 pmpmo_miss pmpmo
ta pmpmob pmpmo

***** scale creation, pm outcome 
* offered or used alcohol, substances or cigarettes
tab1 pmse01 pmsu01 pmcu01

* pnas, positve and negative affect measures 
tab1 pman01 pman02 pman03 pman04 pmna01 pmna02 pmde01 pmde02 pmde03 pmde04 pmde05 pmpa01 pmpa02 pmpa03 pmpa04

* pnas anxiety subscale - pm
egen pmanx=rowmean(pman01 pman02 pman03 pman04)
replace pmanx=pmanx*4
egen pmanx_miss=rowmiss(pman01 pman02 pman03 pman04)
gen pmanxb=cond(pmanx==0,0,cond(pmanx>0 & pmanx~=.,1,.))
lab var pmanx_miss "number of missing pm pnas anxiety questions"
lab var pmanx "pm pnas - anxiety"
lab var pmanxb "pm pnas - anxiety - binary"
tab1 pmanx_miss pmanx
ta pmanxb pmanx

* pnas depression subscale - pm
egen pmdep=rowmean(pmde01 pmde02 pmde03 pmde04 pmde05)
replace pmdep=pmdep*5
egen pmdep_miss=rowmiss(pmde01 pmde02 pmde03 pmde04 pmde05)
gen pmdepb=cond(pmdep==0,0,cond(pmdep>0 & pmdep~=.,1,.))
lab var pmdep_miss "number of missing pm pnas depression questions"
lab var pmdep "pm pnas - depression"
lab var pmdepb "pm pnas - depression - binary"
tab1 pmdep_miss pmdep

* pnas positive affect subscale - pm
egen pmpos=rowmean(pmpa01 pmpa02 pmpa03 pmpa04)
replace pmpos=pmpos*4
egen pmpos_miss=rowmiss(pmpa01 pmpa02 pmpa03 pmpa04)
gen pmposb=cond(pmpos==0,0,cond(pmpos>0 & pmpos~=.,1,.))
lab var pmpos_miss "number of missing pm pnas positive affect questions"
lab var pmpos "pm pnas - positive affect"
lab var pmposb "pm pnas - positive affect - binary"
tab1 pmpos_miss pmpos

* other negative affect: angry, bored, irritable, stressed out - pm
tab1 pmna01 pmna02 pmir01 asst01

* conduct disorder - pm
tab1 pmcd01 pmcd02 pmcd03 pmcd05 pmcd07 pmcd09
egen pmcd=rowmean(pmcd01 pmcd02 pmcd03 pmcd05 pmcd07 pmcd09)
replace pmcd=pmcd*6
egen pmcd_miss=rowmiss(pmcd01 pmcd02 pmcd03 pmcd05 pmcd07 pmcd09)
gen pmcdb=cond(pmcd==0,0,cond(pmcd>0 & pmcd~=.,1,.))
lab var pmcd_miss "number of missing pm pnas conduct disorder questions"
lab var pmcd "pm pnas - conduct disorder"
lab var pmcdb "pm pnas - conduct disorder - binary"
tab1 pmcd_miss pmcd

* conduct disorder with substance use - pm
tab1 pmcd01 pmcd02 pmcd03 pmcd05 pmcd07 pmcd09 pmsu01 pmcu01
egen pmcdsub=rowmean(pmcd01 pmcd02 pmcd03 pmcd05 pmcd07 pmcd09 pmsu01 pmcu01)
replace pmcdsub=pmcdsub*8
egen pmcdsub_miss=rowmiss(pmcd01 pmcd02 pmcd03 pmcd05 pmcd07 pmcd09 pmsu01 pmcu01)
gen pmcdsubb=cond(pmcdsub==0,0,cond(pmcdsub>0 & pmcdsub~=.,1,.))
lab var pmcdsub_miss "number of missing pm pnas conduct disorder and substance use questions"
lab var pmcdsub "pm pnas - conduct disorder and substance use"
lab var pmcdsubb "pm pnas - conduct disorder and substance use - binary"
tab1 pmcdsub_miss pmcdsub

* health risk behaviors - pm
tab1 pmij01 pmij02 pmij03 pmij04
egen pmhrb=rowmean(pmij01 pmij02 pmij03 pmij04)
replace pmhrb=pmhrb*4
egen pmhrb_miss=rowmiss(pmij01 pmij02 pmij03 pmij04)
gen pmhrbb=cond(pmhrb==0,0,cond(pmhrb>0 & pmhrb~=.,1,.))
lab var pmhrb_miss "number of missing pm pnas health risk behavior questions"
lab var pmhrb "pm pnas - health risk behavior"
lab var pmhrbb "pm pnas - health risk behavior - binary"
tab1 pmhrb_miss pmhrb

pwcorr pmetv pmets pmnx04  pmnx01 pmnx07 pmpx02 pmanx pmdep pmpos pmna01 pmna02 pmir01 pmcd pmhrb

recode amsq03 (1 2=0) (3 4=1), gen(amsq03b)

***** new code that loops through all variables to create the sum score scales
gen asir01=asir02

local tri am as pm
local shrconlst /*anx dep pos*/ ang ir
local amconlst `shrconlst' /*slq*/
local asconlst `shrconlst' /*ad pmo*/
local pmconlst `shrconlst' /*   pmo cd cdsub ets etv hrb*/

local anx an01 an02 an03 an04
local dep de01 de02 de03 de04 de05
local pos pa01 pa02 pa03 pa04
local ang na01
local ir ir01
local slq sq03
local ad ad01 ad02 ad03 ad04 ad05 ad06
local pmo pm01 pm02 pm03
local cd cd01 cd02 cd03 cd05 cd07 cd09
local cdsub cd01 cd02 cd03 cd05 cd07 cd09 su01 cu01
local ets ws01 ws02 ws03 ws04
local etv wv01 wv02 wv03 wv04
local hrb ij01 ij02 ij03 ij04

local anx_lab pnas - anxiety
local dep_lab pnas - depression
local pos_lab pnas - positive affect
local ang_lab anger
local ir_lab irritability
local slq_lab sleep_quality
local ad_lab attention-deficit/hyperactivity problems
local pmo_lab parental monitoring
local cd_lab pnas - conduct disorder
local cdsub_lab pnas - conduct disorder and substance use
local ets_lab xposure to substances at home school neighborhood or somewhere else
local etv_lab exposure to fighting at home school neighborhood or somewhere else
local hrb_lab pnas - health risk behavior

*** all items should be on the same scale to be averaged!!!
foreach y of local tri {
	foreach x of local `y'conlst {
		local `y'`x' 
		di "`y'`x'" 
		foreach z of local `x' {
			local `y'`x' ``y'`x'' `y'`z'
		}
		di "``y'`x''"
		tab1 ``y'`x''
		egen `y'`x'=rowmean(``y'`x'')
		local n_items : word count ``y'`x''
		egen `y'`x'_nm=rowmiss(``y'`x'')
		replace `y'`x'=cond(`y'`x'_nm/`n_items'<=.5,`y'`x'*`n_items',.)
		gen `y'`x'_b=cond(`y'`x'==0,0,cond(`y'`x'>0 & `y'`x'~=.,1,.))
		lab var `y'`x'_nm "number of missing `y' ``x'_lab' questions"
		lab var `y'`x' "`y' ``x'_lab'"
		lab var `y'`x'_b "`y' ``x'_lab' - binary"
		tab1 `y'`x' `y'`x'_b `y'`x'_nm
	}
}

*****
global cvlst dtsqbb amanx amdep aspos asanx asdep aspos asad pmetv pmets pmanx pmdep pmpos pmcd pmcdsub pmhrb 
global cvblst amanxb amdepb asposb asanxb asdepb asposb asadb pmetvb pmetsb pmanxb pmdepb pmposb pmcdb pmcdsubb pmhrbb 
global vlst pmnx04 pmnx01 pmnx07 pmpx02 pmse01 pmsu01 pmcu01
local alst $cvlst $cvblst $vlst
local cvlst pmtu19 pmtu20


*des $cvlst $cvblst $vlst 
*sum $cvlst $cvblst $vlst 

************************************* code grom Maddie
* Time texting
*recode pmtu08 (1=.5) (2=1.5) (3=3.5) (4=5), gen(pmtu08r)
*lab def pmtu08r 0.5 "less than one hour" 1.5 "1-2 hours" 3.5 "3-4 hours" 4 "more than four hours"
*lab val pmtu08r pmtu08r
recode pmtu08 (1 2=0) (3 4=1), gen(pmtu08b)
lab def pmtu08b 0 "less than 3 hours, low use" 1 "more than 3 hours, high use" 
lab val pmtu08b pmtu08b

* number of texts per day
*gen pmtu09b=cond(pmtu09<=60,0,cond(mdpmtu09>60 & mdpmtu09~=.,1,.))
*la var pmtu09b "# of text messaging per day, binary"
*la de pmtu09b 0 "low texters" 1 "high texters"
*la val pmtu09b pmtu09b

* number of texts per day, person median, 
egen mdpmtu09=median(pmtu09), by(id)
la var mdpmtu09 "# of texts sent per day, person median"
gen mdpmtxts=cond(mdpmtu09==0,0,cond(mdpmtu09>0 & mdpmtu09<=60,1,cond(mdpmtu09>60 & mdpmtu09~=.,2,.)))
la var mdpmtxts "# of text messaging per day, person median, trinomial"
la de mdpmtxts 0 "non or low texters" 1 "low texters" 2 "high texters"
la val mdpmtxts mdpmtxts

* number of texts per day, person median, binary
gen mdpmtxtsb=cond(mdpmtu09<=60,0,cond(mdpmtu09>60 & mdpmtu09~=.,1,.))
la var mdpmtxtsb "# of text messaging per day, person median, binary"
la de mdpmtxtsb 0 "non or low texters" 1 "high texters"
la val mdpmtxtsb mdpmtxtsb

* number of texts per day
gen pmtu09b=cond(pmtu09<=60,0,cond(pmtu09>60 & pmtu09~=.,1,.))
la var pmtu09b "# of text messaging per day, binary"
la val pmtu09b mdpmtxtsb

* cage binary
recode cagec (11/13=0) (14/15=1), gen(cagecb_old)
lab def cagecb_old 0 "age 11-13" 1 "age 14 -15, older"
lab val cagecb_old cagecb_old
lab var cagecb_old "older repondents, age 14/15, binary"

* DAILY texting impairment
gen pmtu14r=pmtu14-1
egen pmtxtimpb=rowtotal(pmtu14r pmtu15-pmtu17)
replace pmtxtimpb=1 if pmtxtimpb>0 & pmtxtimpb~=1
lab def pmtxtimpb 0 "no" 1 "yes"
lab val pmtxtimpb pmtxtimpb
lab var pmtxtimpb "DAILY texting impairment"

* DAILY texting distress
recode pmtu19 (1/2=0) (3=1), gen(pmtxtdistb)
lab def pmtxtdistb 0 "1/2" 1 "3, distress"
lab val pmtxtdistb pmtxtdistb
lab var pmtxtdistb "DAILY texting distress"
**************************************


***** flag for first row of each id *****
gen person_level=.
bysort id: replace person_level=1 if _n==1
lab var person_level "identifies to keep only one entry/person"
* to use person level only variables use the following syntax:
*keep if person_level==1

***** Child Baseline Data *****
* 0/1 version of cstress created in the baseline by Mike using SPSS already
* here original cstress variable with 1/2 values will be dropped and the stressd renamed to the original name

local cstress home school friend other tot
local home 1/4
local school 5/9 
local friend 10/13
local other 14/20
local tot 1/20
local strs strs

*** all items should be on the same scale to be averaged!!!
foreach x of local cstress {
	local y
	di "`x'" 
	di ``x''
	foreach z of num ``x'' {
		local y `y' cstress`z'd
	}
	di "`y'"
	tab1 `y'
	egen `strs'_`x'=rowmean(`y')
	local n_items : word count `y'
	egen `strs'_`x'_nm=rowmiss(`y')
	replace `strs'_`x'=cond(`strs'_`x'_nm/`n_items'<=.5,`strs'_`x'*`n_items',.)
	sum `strs'_`x' if first==1
	gen `strs'_`x'_c=`strs'_`x'-r(mean)
	gen `strs'_`x'_z=(`strs'_`x'-r(mean))/r(sd)
	gen `strs'_`x'_cb=cond(`strs'_`x'_c<0,0,cond(`strs'_`x'_c>=0 & `strs'_`x'_c~=.,1,.))
	gen `strs'_`x'_b=cond(`strs'_`x'==0,0,cond(`strs'_`x'>0 & `strs'_`x'~=.,1,.))
	lab var `strs'_`x'_nm "number of missing `x' stress questions"
	lab var `strs'_`x' "stress related to `x'"
	lab var `strs'_`x'_c "stress related to `x', mean centered"
	lab var `strs'_`x'_z "stress related to `x', zscore"
	lab var `strs'_`x'_cb "stress related to `x', binary mean split"
	lab var `strs'_`x'_b "stress related to `x', binary zero or other"
	tab1 `strs'_`x' `strs'_`x'_b `strs'_`x'_nm
}

drop cstress1-cstress20
rename cstress*d cstress*
rename cstressdtot tot_cstress

*** reverse coding and create binary version
sum ccirc_iso 
gen ccirc_iso_r=r(max)-ccirc_iso+1
recode ccirc_iso (1/2=1) (3/5=0), gen(ccirc_iso_rb12)
recode ccirc_iso (1/3=1) (4/5=0), gen(ccirc_iso_rb123)
sum psoc_isoc
gen psoc_isoc_r=r(max)-psoc_isoc+1
recode psoc_isoc (1/2=1) (3/5=0), gen(psoc_isoc_rb12)
recode psoc_isoc (1/3=1) (4/5=0), gen(psoc_isoc_rb123)
recode cladderrc (1/2=1) (3/5=0), gen(cladderrcb12)
lab def poor 0 "not poor" 1 "poor"
lab val cladderrcb12 poor

recode amdx01 (1/2=0) (3=1), gen(amdx01b)


*** center the moderator variables from the baseline 
local centering cladderrc ccirc_iso_r
foreach x of local centering {
	sum `x' if first==1
	gen `x'_c=`x'-r(mean)
	gen `x'_z=(`x'-r(mean))/r(sd)
	gen `x'_cb=cond(`x'_c<0,0,cond(`x'_c>=0 & `x'_c~=.,1,.))
}


gen pangercr=pangerc-1
lab var pangercr "child anger summary score, parent report"
