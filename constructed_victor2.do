

*** combining constructed variables
gen pmanxdep=pmanxr+pmdepr
gen pmanxdep_b=pmanxbr+pmdepbr
recode pmanxdep_b (2/3=1)
*gen pmanxang=pmanxbr+pmang
*gen pmangdep=pmang+pmdepbr
*gen pmanxangdep=pmanxbr+pmdepbr+pmang
*recode pmanxdep pmanxang pmangdep pmanxangdep (2/3=1), gen(pmanxdep_b pmanxang_b pmangdep_b pmanxangdep_b)

*** create the daily average measure
local daily anx dep anxbr depbr ir ang
foreach x of local daily {
	egen daily`x'=rowmean(am`x' as`x' pm`x')
	egen daily`x'_nm=rowmiss(am`x' as`x' pm`x')
	replace daily`x'=. if daily`x'_nm/3>.5
	*replace daily`x'=cond(`x'_nm/3<=.5,,.)
	gen daily`x'b=daily`x'
	replace daily`x'b=1 if daily`x'~=0 & daily`x'~=.
	lab var daily`x' "daily measure of aggregated am as pm "
	lab var daily`x' "daily measure of aggregated am as pm, binary"
}


gen envprobr_b20=cond(envprobr<0.55,0,cond(envprobr>=0.55,1,.))
gen daycountmaxc=daycountmax-30

*** create lagged and lagged average measures as predictors
local vlst pmetvbr 
local t dlocaln2
local tdif 2
sort id `t'
capture drop n
gen n=_n
foreach v in `vlst' {
	forvalues td=1/`tdif' {
		gen `v'lag_`td'=.
		lab var `v'lag_`td' "variable `v' with a `td'-day lag"
		gen `v'td`td'=.
		forvalues n= 2/`c(N)' {
			local n1=`n'-`td'
			quietly: replace `v'lag_`td'= `= `v'[`n1']' if n==`n'
			quietly: replace `v'td`td'= `= `t'[`n']' - `= `t'[`n1']' if n==`n'
		}
		foreach tdm of num 1/`td' {
			by id: replace `v'lag_`td'=. if _n==_N-(`tdm'-1)
			by id: replace `v'td`td'=. if _n==_N-(`tdm'-1)
		}
		replace `v'lag_`td'=. if `v'td`td'~=`td'
		drop `v'td`td'
		
		if `td'>1 {
			local avlst
			local n1lst
			forvalues td0=1/`td' {
				local avlst `avlst' `v'lag_`td0' 
				local n1lst="`n1lst'"+"`td0'"
			}
			local n0lst="0"+"`n1lst'"
			egen `v'laga_`n1lst'=rowmean(`avlst')
			egen `v'laga_`n0lst'=rowmean(`v' `avlst')
			gen `v'laga_`n1lst'b=`v'laga_`n1lst'
			gen `v'laga_`n0lst'b=`v'laga_`n0lst'
			replace `v'laga_`n1lst'b=1 if `v'laga_`n1lst'b~=0 & `v'laga_`n1lst'b~=.
			replace `v'laga_`n0lst'b=1 if `v'laga_`n0lst'b~=0 & `v'laga_`n0lst'b~=.
			lab var `v'laga_`n1lst' "variable `v' as the average of `n1lst'-day lag"
			lab var `v'laga_`n0lst' "variable `v' as the average of `n0lst'-day lag"
			lab var `v'laga_`n1lst'b "variable `v' as the average of `n1lst'-day lag, binary"
			lab var `v'laga_`n0lst'b "variable `v' as the average of `n0lst'-day lag, binary"
		}
	}
}
drop n

*** create next day measures as outcomes
local vlst amsq03b amsq04 amsq05 amdx01b aman04 amde05 
local t dlocaln2
local tdif 1
sort id `t'
capture drop n
gen n=_n
foreach v in `vlst' {
	forvalues td=1/`tdif' {
		gen `v'nxt_`td'=.
		lab var `v'nxt_`td' "variable `v' measured `td'-day after"
		gen `v'td`td'=.
		forvalues n= 2/`c(N)' {
			local n1=`n'-`td'
			quietly: replace `v'nxt_`td'= `= `v'[`n']' if n==`n1'
			quietly: replace `v'td`td'= `= `t'[`n']' - `= `t'[`n1']' if n==`n1'
		}
		foreach tdm of num 1/`td' {
			by id: replace `v'nxt_`td'=. if _n==_N-(`tdm'-1)
			by id: replace `v'td`td'=. if _n==_N-(`tdm'-1)
		}
		replace `v'nxt_`td'=. if `v'td`td'~=`td'
		drop `v'td`td'
	}
}
drop n

*** center the person means by population means
sort id 
local centering pmetvr pmetvbrlag_1 dailyanx dailydep dailyanxbrb dailydepbrb asadbr pmcdbr agna01br agir01br pmtxtdistb pmtxtimpb pmtu09b pmtu08b ///
	pdepctot panxctot pconctot padhctot
*pmcdsubr pmdepr pmanxr pmhrbr pmanxdep pmetvbr pmcdsubbr pmir pmhrbbr pmposbr pmang pmanxbr pmdepbr pmanxdep_b amsq03b amsq04
foreach x of local centering {
	by id: egen m`x'=mean(`x') //if `x'~=.
	sum m`x' if first==1
	gen m`x'c=m`x'-r(mean)
	*gen m`x'_z=(m`x'-r(mean))/r(sd)
	*gen m`x'_cb=cond(m`x'_c<0,0,cond(m`x'_c>=0 & m`x'_c~=.,1,.))
	lab var m`x' "person mean"
	lab var m`x'c "person mean, centered by sample mean"
}

*** center the daily measure by person means
sort id 
local centering dailyanxbrb dailydepbrb agna01br agir01br asadbr pmcdbr pmtu08b pmtu09b pmtxtimpb
foreach x of local centering {
	capture: by id: egen m`x'=mean(`x') //if `x'~=.
	gen `x'c=`x'-m`x'
	*lab var m`x' "person mean"
	lab var `x'c "daily measure, centered by person mean"
}
