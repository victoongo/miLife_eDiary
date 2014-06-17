/*
this is the current working version of the analaysis for paper 1. 
output in long form for easy maintainence (drop some unwanted info and do some merging) and also easy manipulation in Stata. 
*/
libname etv "D:\milife";
PROC IMPORT OUT=daywide
            FILE="D:\milife\master_daywide.dta"
            DBMS=STATA REPLACE;
RUN;
/*data daywide; set etv.daywide_a1; run;*/

%macro loopdv(fn,dv,iv,mod,cm);
	%let model12=;
	%let model3=;
	%let model4=;
	%if &dv.~= %then
	%do i=1 %to %sysfunc(countw(&dv.));
		%let dvi=%scan(&dv.,&i.);
/*
		*MODEL 1: empty multilevel model for icc; 
		title "Model 1, &dvi. binary empty model";
		proc glimmix data=daywide method=rspl noclprint noitprint;
			class id daycount;
			model &dvi.(event="1")= /link=logit dist=bin solution cl ddfm=bw; 
			random intercept /subject=id type=un g gcorr solution cl; 
			covtest "vs. Model 0: no random intercept" 0 /estimates wald cl;
			nloptions tech=newrap;
			ods exclude solutionr;
			ods output covparms=&dvi.1cp;
		run; title;
		****icc output;
		data &dvi.icc (keep=depvar icc); 
			set &dvi.1cp(where=(CovParm='UN(1,1)')); 
			depvar="&dvi."; 
			icc=Estimate/(Estimate+3.29);
		run;
		title "ICC from &dvi. binary empty model";
		proc print data=&dvi.icc noobs label; var icc; run; title;

		*MODEL 2: testing autocorrelation parameter; 
		title "Model 2, &dvi. binary empty model with autocorrelation";
		proc glimmix data=daywide method=rspl noclprint noitprint;
			class id daycount;
			model &dvi.(event="1")= /link=logit dist=bin solution cl ddfm=bw; 
			random intercept /subject=id type=un g gcorr solution cl; 
			random daycount /subject=id type=sp(pow)(daycount) residual; 
			covtest "vs. Model 0: no random intercept" 0 . /estimates wald cl;
			covtest "vs. Model 1: no autocorrelation" . 0 /estimates wald cl; 
			nloptions tech=newrap;
			ods exclude solutionr;
			ods output covparms=&dvi.2cp;
		run; title;
		data &dvi.agc (keep=depvar CovParm Estimate StdErr ProbZ); 
			set &dvi.2cp(where=(CovParm='SP(POW)')); 
			depvar="&dvi."; 
		run;
		data model12&dvi.; merge &dvi.icc &dvi.agc; by depvar; run;
*/
		%let wpcre=;
		%let wpcrei=;
		%if &iv.~= %then
		%do j=1 %to %sysfunc(countw(&iv.));
			%let ivi=%scan(&iv.,&j.);
/*
			*MODEL 3: testing within-person effect of &ivi. on &dvi.; 
			title "&dvi. Model 3a, &dvi. within-person effect of &ivi., no covariates, no random effect";
			proc glimmix data=daywide method=rspl noclprint noitprint;
				class id daycount;
				model &dvi.(event="1") = m&ivi.c &ivi. /link=logit dist=bin solution cl ddfm=bw ddf=149 150; 
				random intercept /subject=id type=un g gcorr solution cl; 
				random daycount /subject=id type=sp(pow)(daycount) residual; 
				estimate "OR: person-mean &ivi." m&ivi.c 1 / exp cl; 
				estimate "OR: within-person &ivi." &ivi. 1 / exp cl; 
				estimate "OR: total between-person &ivi. effect" m&ivi.c 1 &ivi. 1 /exp cl; 
				covtest "random effects significance tests" . . . /estimates wald cl;
				nloptions tech=newrap;
				ods exclude solutionr;
			run; title;

			title "&dvi. Model 3b, &dvi. within-person effect of &ivi., no covariates, WITH random effect";
			proc glimmix data=daywide method=rspl noclprint noitprint;
				class id daycount;
				model &dvi.(event="1")= m&ivi.c &ivi. /link=logit dist=bin solution cl ddfm=bw ddf=149 150; 
				random intercept &ivi. /subject=id type=un g gcorr solution cl; 
				random daycount /subject=id type=sp(pow)(daycount) residual; 
				estimate "OR: person-mean &ivi." m&ivi.c 1 / exp cl; 
				estimate "OR: within-person &ivi." &ivi. 1 / exp cl; 
				estimate "OR: total between-person &ivi. effect" m&ivi.c 1 &ivi. 1 /exp cl; 
				covtest "random effects significance tests" . . . . . /estimates wald cl;
				nloptions tech=newrap;
				ods exclude solutionr;
				ods output ParameterEstimates=&dvi._&ivi.3bf solutionr=&dvi._&ivi.3br;
			run; title;
*/
			title "Model 3c, &dvi. within-person effect of &ivi., WITH covariates, WITH random effect";
			proc glimmix data=daywide method=rspl noclprint noitprint;
				class id daycount;
				model &dvi.(event="1")= m&ivi.c &ivi. /**daycountmaxc daydur wknd**/ /link=logit dist=bin solution cl ddfm=bw ddf=148 148 150 150 150; 
				random intercept &ivi. /subject=id type=un g gcorr solution cl; 
				random daycount /subject=id type=sp(pow)(daycount) residual; 
				estimate "OR: person-mean &ivi." m&ivi.c 1 / exp cl; 
				estimate "OR: within-person &ivi." &ivi. 1 / exp cl; 
				estimate "OR: total between-person &ivi. effect" m&ivi.c 1 &ivi. 1 /exp cl;
				**estimate "OR: number of study days" daycountmaxc 1 /exp cl;
				**estimate "OR: time, centered at day 1" daydur 1 /exp cl; 
				**estimate "OR: weekend" wknd 1 /exp cl;  
				covtest "random effects significance tests" . . . . . /estimates wald cl;
				nloptions tech=newrap;
				ods exclude solutionr;
				ods output ParameterEstimates=&dvi._&ivi.3cf solutionr=&dvi._&ivi.3cr estimates=&dvi._&ivi.3ce;
			run; title;
			data &dvi._&ivi.wpcre (keep=depvar Label ExpEstimate Probt ExpLower ExpUpper indvar model); 
				set &dvi._&ivi.3ce(where=(Label="OR: within-person &ivi.")); 
				depvar="&dvi."; 
				indvar="&ivi.";
				model=3;
			run;
			%let wpcre=&wpcre. &dvi._&ivi.wpcre;
/*
			*Create Intercepts and Reactivity Slopes for each person, from Models Models 3B&C; 
			***MODEL 3B***; 
			data &dvi._&ivi.3br;
			length Effect $ 12; 
			set &dvi._&ivi.3br;
			run;
			data &dvi._&ivi.3bf;
			length Effect $ 12; 
			set &dvi._&ivi.3bf;
			run;
			data &dvi._&ivi.blp3b; * creating a data set that will add the random deviations to the fixed effect estimates;
			merge &dvi._&ivi.3br(where=(Effect='Intercept') rename=(Estimate=ri3b&dvi._&ivi.))
			&dvi._&ivi.3br(where=(Effect='pmetvbr' ) rename=(Estimate=rs3b&dvi._&ivi.));
			if _n_ = 1 then merge
			&dvi._&ivi.3bf(where=(Effect='Intercept') rename=(Estimate=fi3b&dvi._&ivi.))
			&dvi._&ivi.3bf(where=(Effect='pmetvbr') rename=(Estimate=fs3b&dvi._&ivi.));
			int3b&dvi._&ivi. = fi3b&dvi._&ivi. + ri3b&dvi._&ivi.;
			slp3b&dvi._&ivi. = fs3b&dvi._&ivi. + rs3b&dvi._&ivi.;
			idst = substr(Subject,3,5);
			id = input(idst,BEST12.);
			length id 4;
			label id ="subject id, child baseline"
				  int3b&dvi._&ivi.="person intercept, model 3b etv-->&dvi._&ivi."
				  slp3b&dvi._&ivi.="person reactivity slope, model 3b etv-->&dvi._&ivi.";
			keep id ri3b&dvi._&ivi. fi3b&dvi._&ivi. int3b&dvi._&ivi. rs3b&dvi._&ivi. fs3b&dvi._&ivi. slp3b&dvi._&ivi. ;
			run;
			proc sort data=&dvi._&ivi.blp3b; by id;
			proc sort data=daywide; by id dlocaln2;
			data daywide; merge daywide &dvi._&ivi.blp3b; by id;
			run; 

			***MODEL 3C***; 
			data &dvi._&ivi.3cr;
			length Effect $ 12; 
			set &dvi._&ivi.3cr;
			run;
			data &dvi._&ivi.3cf;
			length Effect $ 12; 
			set &dvi._&ivi.3cf;
			run;
			data &dvi._&ivi.blp3c; * creating a data set that will add the random deviations to the fixed effect estimates ;
			merge &dvi._&ivi.3cr(where=(Effect='Intercept') rename=(Estimate=ri3c&dvi._&ivi.))
			&dvi._&ivi.3cr(where=(Effect='pmetvbr' ) rename=(Estimate=rs3c&dvi._&ivi.));
			if _n_ = 1 then merge
			&dvi._&ivi.3cf(where=(Effect='Intercept') rename=(Estimate=fi3c&dvi._&ivi.))
			&dvi._&ivi.3cf(where=(Effect='pmetvbr') rename=(Estimate=fs3c&dvi._&ivi.));
			int3c&dvi._&ivi. = fi3c&dvi._&ivi. + ri3c&dvi._&ivi.;
			slp3c&dvi._&ivi. = fs3c&dvi._&ivi. + rs3c&dvi._&ivi.;
			idst = substr(Subject,3,5);
			id = input(idst,BEST12.);
			length id 4;
			label id ="subject id, child baseline"
				  int3c&dvi._&ivi.="person intercept, model 3c etv-->&dvi._&ivi."
				  slp3c&dvi._&ivi.="person reactivity slope, model 3c etv-->&dvi._&ivi.";
			keep id ri3c&dvi._&ivi. fi3c&dvi._&ivi. int3c&dvi._&ivi. rs3c&dvi._&ivi. fs3c&dvi._&ivi. slp3c&dvi._&ivi. ;
			run;
			proc sort data=&dvi._&ivi.blp3c; by id;
			proc sort data=daywide; by id dlocaln2;
			data etv.daywide_model3; merge daywide &dvi._&ivi.blp3c; by id;
			run; 
*/
			
			%if &mod.~= %then
			%do k=1 %to %sysfunc(countw(&mod.));
				%let modi=%scan(&mod.,&k.);
/*
				*MODEL 4: &ivi. with &modi. interactions;
				title "&dvi. Model 4a, &dvi. within-person effect of &ivi., no covariates, no random effect";
				proc glimmix data=daywide method=rspl noclprint noitprint;
					class id daycount;
					model &dvi.(event="1")= m&ivi.c &modi. &ivi. &modi.*&ivi. /link=logit dist=bin solution cl ddfm=bw ddf=148 148 149 149; 
					random intercept /subject=id type=un g gcorr solution cl; 
					random daycount /subject=id type=sp(pow)(daycount) residual; 
					estimate "OR: person-mean &ivi." m&ivi.c 1 / exp cl; 
					estimate "OR: &modi. effect, &modi.=1" &modi. 1 /exp cl; 
					estimate "OR: &modi. X within-person &ivi." &modi.*&ivi. 1 /exp cl; 
					estimate "OR: within-person &ivi., for &modi.=0" &ivi. 1 &modi.*&ivi. 0 / exp cl; 
					estimate "OR: within-person &ivi., for &modi.=1" &ivi. 1 &modi.*&ivi. 1 / exp cl; 
					covtest "random effects significance tests" . . . /estimates wald cl;
					nloptions tech=newrap;
					ods exclude solutionr;
				run; title;
				 
				title "&dvi. Model 4b, &dvi. within-person effect of &ivi., no covariates, WITH random effect";
				proc glimmix data=daywide method=rspl noclprint noitprint;
					class id daycount;
					model &dvi.(event="1")= m&ivi.c &modi. &ivi. &modi.*&ivi. /link=logit dist=bin solution cl ddfm=bw ddf=148 148 149 149; 
					random intercept &ivi. /subject=id type=un g gcorr solution cl; 
					random daycount /subject=id type=sp(pow)(daycount) residual; 
					estimate "OR: person-mean &ivi." m&ivi.c 1 / exp cl; 
					estimate "OR: &modi. effect, &modi.=1" &modi. 1 /exp cl; 
					estimate "OR: &modi. X within-person &ivi." &modi.*&ivi. 1 /exp cl; 
					estimate "OR: within-person &ivi., for &modi.=0" &ivi. 1 &modi.*&ivi. 0 / exp cl; 
					estimate "OR: within-person &ivi., for &modi.=1" &ivi. 1 &modi.*&ivi. 1 / exp cl; 
					covtest "random effects significance tests" . . . . . /estimates wald cl;
					nloptions tech=newrap;
					ods exclude solutionr;
					ods output ParameterEstimates=&dvi._&ivi._&modi.4bf solutionr=&dvi._&ivi._&modi.4br;
				run; title;
*/
				title "Model 4c, &dvi. within-person effect of &ivi., WITH covariates, WITH random effect, BM";
				proc glimmix data=daywide method=rspl noclprint noitprint;
					class id daycount;
					model &dvi.(event="1")= m&ivi.c &modi. &ivi. &modi.*&ivi. /**daycountmaxc daydur wknd**/ 
											   /link=logit dist=bin solution cl ddfm=bw ddf=147 147 147 149 149 150 150; 
					random intercept &ivi. /subject=id type=un g gcorr solution cl; 
					random daycount /subject=id type=sp(pow)(daycount) residual; 
					estimate "OR: person-mean &ivi." m&ivi.c 1 / exp cl; 
					estimate "OR: &modi. effect, &modi.=1" &modi. 1 /exp cl; 
					estimate "OR: &modi. X within-person &ivi." &modi.*&ivi. 1 /exp cl; 
					estimate "OR: within-person &ivi., for &modi.=0" &ivi. 1 &modi.*&ivi. 0 / exp cl; 
					estimate "OR: within-person &ivi., for &modi.=1" &ivi. 1 &modi.*&ivi. 1 / exp cl; 
					**estimate "OR: number of study days" daycountmaxc 1 /exp cl;
					**estimate "OR: time, centered at day 1" daydur 1 /exp cl; 
					**estimate "OR: weekend" wknd 1 /exp cl;  
					covtest "random effects significance tests" . . . . . /estimates wald cl;
					nloptions tech=newrap;
					ods exclude solutionr;
					ods output ParameterEstimates=o&i._&j._b&k.4cf solutionr=o&i._&j._b&k.4cr  estimates=o&i._&j._b&k.4ce;
				run; title;
				data o&i._&j._b&k.wpcrei (keep=depvar Label ExpEstimate Probt ExpLower ExpUpper indvar modvar model); 
					set o&i._&j._b&k.4ce(where=(Label="OR: &modi. effect, &modi.=1" 
												or Label="OR: &modi. X within-person &ivi."
												or Label="OR: within-person &ivi., for &modi.=0"
												or Label="OR: within-person &ivi., for &modi.=1"));
					depvar="&dvi."; 
					indvar="&ivi.";
					modvar="&modi.";
					model=4;
				run;
				%let wpcrei=&wpcrei. o&i._&j._b&k.wpcrei;
/*				
				*Create Intercepts and Reactivity Slopes for each person, from Models Models 4B&C;
				***MODEL 4B***; 
				data &dvi._&ivi._&modi.4br;
				length Effect $ 12; 
				set &dvi._&ivi._&modi.4br;
				run;
				data &dvi._&ivi._&modi.4bf;
				length Effect $ 12; 
				set &dvi._&ivi._&modi.4bf;
				run;
				data &dvi._&ivi._&modi.blp4b; * creating a data set that will add the random deviations to the fixed effect estimates ;
				merge &dvi._&ivi._&modi.4br(where=(Effect='Intercept') rename=(Estimate=ri4b&dvi._&ivi._&modi.))
				&dvi._&ivi._&modi.4br(where=(Effect='pmetvbr' ) rename=(Estimate=rs4b&dvi._&ivi._&modi.));
				if _n_ = 1 then merge
				&dvi._&ivi._&modi.4bf(where=(Effect='Intercept') rename=(Estimate=fi4b&dvi._&ivi._&modi.))
				&dvi._&ivi._&modi.4bf(where=(Effect='pmetvbr') rename=(Estimate=fs4b&dvi._&ivi._&modi.));
				int4b&dvi._&ivi._&modi. = fi4b&dvi._&ivi._&modi. + ri4b&dvi._&ivi._&modi.;
				slp4b&dvi._&ivi._&modi. = fs4b&dvi._&ivi._&modi. + rs4b&dvi._&ivi._&modi.;
				idst = substr(Subject,3,5);
				id = input(idst,BEST12.);
				length id 4;
				label id ="subject id, child baseline"
					  int4b&dvi._&ivi._&modi.="person intercept, model 4b etv-->&dvi._&ivi._&modi."
					  slp4b&dvi._&ivi._&modi.="person reactivity slope, model 4b etv-->&dvi._&ivi._&modi.";
				keep id ri4b&dvi._&ivi._&modi. fi4b&dvi._&ivi._&modi. int4b&dvi._&ivi._&modi. rs4b&dvi._&ivi._&modi. fs4b&dvi._&ivi._&modi. slp4b&dvi._&ivi._&modi. ;
				run;
				proc sort data=&dvi._&ivi._&modi.blp4b; by id;
				proc sort data=daywide; by id dlocaln2;
				data daywide; merge daywide &dvi._&ivi._&modi.blp4b; by id;
				run; 

				***MODEL 4C***; 
				data &dvi._&ivi._&modi.4cr;
				length Effect $ 12; 
				set &dvi._&ivi._&modi.4cr;
				run;
				data &dvi._&ivi._&modi.4cf;
				length Effect $ 12; 
				set &dvi._&ivi._&modi.4cf;
				run;
				data &dvi._&ivi._&modi.blp4c; * creating a data set that will add the random deviations to the fixed effect estimates ;
				merge &dvi._&ivi._&modi.4cr(where=(Effect='Intercept') rename=(Estimate=ri4c&dvi._&ivi._&modi.))
					  &dvi._&ivi._&modi.4cr(where=(Effect='pmetvbr' ) rename=(Estimate=rs4c&dvi._&ivi._&modi.));
				if _n_ = 1 then merge
				&dvi._&ivi._&modi.4cf(where=(Effect='Intercept') rename=(Estimate=fi4c&dvi._&ivi._&modi.))
				&dvi._&ivi._&modi.4cf(where=(Effect='pmetvbr') rename=(Estimate=fs4c&dvi._&ivi._&modi.));
				int4c&dvi._&ivi._&modi. = fi4c&dvi._&ivi._&modi. + ri4c&dvi._&ivi._&modi.;
				slp4c&dvi._&ivi._&modi. = fs4c&dvi._&ivi._&modi. + rs4c&dvi._&ivi._&modi.;
				idst = substr(Subject,3,5);
				id = input(idst,BEST12.);
				length id 4;
				label id ="subject id, child baseline"
					  int4c&dvi._&ivi._&modi.="person intercept, model 4c etv-->&dvi._&ivi._&modi."
					  slp4c&dvi._&ivi._&modi.="person reactivity slope, model 4c etv-->&dvi._&ivi._&modi.";
				keep id ri4c&dvi._&ivi._&modi. fi4c&dvi._&ivi._&modi. int4c&dvi._&ivi._&modi. rs4c&dvi._&ivi._&modi. fs4c&dvi._&ivi._&modi. slp4c&dvi._&ivi._&modi. ;
				run;
				proc sort data=&dvi._&ivi._&modi.blp4c; by id;
				proc sort data=daywide; by id dlocaln2;
				data etv.daywide_model4; merge daywide &dvi._&ivi._&modi.blp4c; by id;
				run; 
*/
			%end;
			/*data model4&dvi.; set &wpcrei.; by depvar; run;*/

			%if &cm.~= %then
			%do k=1 %to %sysfunc(countw(&cm.));
				%let cmi=%scan(&cm.,&k.);

			    proc means data=daywide;
			    	var &cmi.;
			    	output out=sdd std=sdx;
			    run;
			    data _null_;
			    	set sdd;
			    	call symput("sd",sdx);
			    run;
				*%let &cmi.std=&sd.;
				*%let &cmi.stdn=-&sd.;
/*
				*MODEL 4: &ivi. with &cmi. interactions;
				title "&dvi. Model 4a, &dvi. within-person effect of &ivi., no covariates, no random effect";
				proc glimmix data=daywide method=rspl noclprint noitprint;
					class id daycount;
					model &dvi.(event="1")= m&ivi.c &cmi. &ivi. &cmi.*&ivi. /link=logit dist=bin solution cl ddfm=bw ddf=148 148 149 149; 
					random intercept /subject=id type=un g gcorr solution cl; 
					random daycount /subject=id type=sp(pow)(daycount) residual; 
					estimate "OR: person-mean &ivi." m&ivi.c 1 / exp cl; 
					estimate "OR: &cmi. effect, &cmi.=1" &cmi. 1 /exp cl; 
					estimate "OR: &cmi. X within-person &ivi." &cmi.*&ivi. 1 /exp cl; 
					estimate "OR: within-person &ivi., for &cmi.=0" &ivi. 1 &cmi.*&ivi. 0 / exp cl; 
					estimate "OR: within-person &ivi., for &cmi.=1" &ivi. 1 &cmi.*&ivi. 1 / exp cl; 
					covtest "random effects significance tests" . . . /estimates wald cl;
					nloptions tech=newrap;
					ods exclude solutionr;
				run; title;
				 
				title "&dvi. Model 4b, &dvi. within-person effect of &ivi., no covariates, WITH random effect";
				proc glimmix data=daywide method=rspl noclprint noitprint;
					class id daycount;
					model &dvi.(event="1")= m&ivi.c &cmi. &ivi. &cmi.*&ivi. /link=logit dist=bin solution cl ddfm=bw ddf=148 148 149 149; 
					random intercept &ivi. /subject=id type=un g gcorr solution cl; 
					random daycount /subject=id type=sp(pow)(daycount) residual; 
					estimate "OR: person-mean &ivi." m&ivi.c 1 / exp cl; 
					estimate "OR: &cmi. effect, &cmi.=1" &cmi. 1 /exp cl; 
					estimate "OR: &cmi. X within-person &ivi." &cmi.*&ivi. 1 /exp cl; 
					estimate "OR: within-person &ivi., for &cmi.=0" &ivi. 1 &cmi.*&ivi. 0 / exp cl; 
					estimate "OR: within-person &ivi., for &cmi.=1" &ivi. 1 &cmi.*&ivi. 1 / exp cl; 
					covtest "random effects significance tests" . . . . . /estimates wald cl;
					nloptions tech=newrap;
					ods exclude solutionr;
					ods output ParameterEstimates=&dvi._&ivi._&cmi.4bf solutionr=&dvi._&ivi._&cmi.4br;
				run; title;
*/
				title "Model 4c, &dvi. within-person effect of &ivi., WITH covariates, WITH random effect, CM";
				proc glimmix data=daywide method=rspl noclprint noitprint;
					class id daycount;
					model &dvi.(event="1")= m&ivi.c &cmi. &ivi. &cmi.*&ivi. /**daycountmaxc daydur wknd**/ 
											   /link=logit dist=bin solution cl ddfm=bw ddf=147 147 147 149 149 150 150; 
					random intercept &ivi. /subject=id type=un g gcorr solution cl; 
					random daycount /subject=id type=sp(pow)(daycount) residual; 
					estimate "OR: person-mean &ivi." m&ivi.c 1 / exp cl; 
					estimate "OR: &cmi. effect" &cmi. 1 /exp cl; 
					estimate "OR: &cmi. X within-person &ivi." &cmi.*&ivi. 1 /exp cl; 
					estimate "OR: within-person &ivi., for low &cmi.=-&sd." &ivi. 1 &cmi.*&ivi. -&sd. / exp cl; 
					estimate "OR: within-person &ivi., for high &cmi.=&sd." &ivi. 1 &cmi.*&ivi. &sd. / exp cl; 
					**estimate "OR: number of study days" daycountmaxc 1 /exp cl;
					**estimate "OR: time, centered at day 1" daydur 1 /exp cl; 
					**estimate "OR: weekend" wknd 1 /exp cl;  
					covtest "random effects significance tests" . . . . . /estimates wald cl;
					nloptions tech=newrap;
					ods exclude solutionr;
					ods output ParameterEstimates=o&i._&j._c&k.4cf solutionr=o&i._&j._c&k.4cr  estimates=o&i._&j._c&k.4ce;
				run; title;
				data o&i._&j._c&k.wpcrei (keep=depvar Label ExpEstimate Probt ExpLower ExpUpper indvar modvar model); 
					set o&i._&j._c&k.4ce(where=(Label="OR: &cmi. effect" 
												or Label="OR: &cmi. X within-person &ivi."
												or Label="OR: within-person &ivi., for low &cmi.=-&sd."
												or Label="OR: within-person &ivi., for high &cmi.=&sd."));
					depvar="&dvi."; 
					indvar="&ivi.";
					modvar="&cmi.";
					model=4;
				run;
				%let wpcrei=&wpcrei. o&i._&j._c&k.wpcrei;
/*				
				*Create Intercepts and Reactivity Slopes for each person, from Models Models 4B&C;
				***MODEL 4B***; 
				data &dvi._&ivi._&cmi.4br;
				length Effect $ 12; 
				set &dvi._&ivi._&cmi.4br;
				run;
				data &dvi._&ivi._&cmi.4bf;
				length Effect $ 12; 
				set &dvi._&ivi._&cmi.4bf;
				run;
				data &dvi._&ivi._&cmi.blp4b; * creating a data set that will add the random deviations to the fixed effect estimates ;
				merge &dvi._&ivi._&cmi.4br(where=(Effect='Intercept') rename=(Estimate=ri4b&dvi._&ivi._&cmi.))
				&dvi._&ivi._&cmi.4br(where=(Effect='pmetvbr' ) rename=(Estimate=rs4b&dvi._&ivi._&cmi.));
				if _n_ = 1 then merge
				&dvi._&ivi._&cmi.4bf(where=(Effect='Intercept') rename=(Estimate=fi4b&dvi._&ivi._&cmi.))
				&dvi._&ivi._&cmi.4bf(where=(Effect='pmetvbr') rename=(Estimate=fs4b&dvi._&ivi._&cmi.));
				int4b&dvi._&ivi._&cmi. = fi4b&dvi._&ivi._&cmi. + ri4b&dvi._&ivi._&cmi.;
				slp4b&dvi._&ivi._&cmi. = fs4b&dvi._&ivi._&cmi. + rs4b&dvi._&ivi._&cmi.;
				idst = substr(Subject,3,5);
				id = input(idst,BEST12.);
				length id 4;
				label id ="subject id, child baseline"
					  int4b&dvi._&ivi._&cmi.="person intercept, model 4b etv-->&dvi._&ivi._&cmi."
					  slp4b&dvi._&ivi._&cmi.="person reactivity slope, model 4b etv-->&dvi._&ivi._&cmi.";
				keep id ri4b&dvi._&ivi._&cmi. fi4b&dvi._&ivi._&cmi. int4b&dvi._&ivi._&cmi. rs4b&dvi._&ivi._&cmi. fs4b&dvi._&ivi._&cmi. slp4b&dvi._&ivi._&cmi. ;
				run;
				proc sort data=&dvi._&ivi._&cmi.blp4b; by id;
				proc sort data=daywide; by id dlocaln2;
				data daywide; merge daywide &dvi._&ivi._&cmi.blp4b; by id;
				run; 

				***MODEL 4C***; 
				data &dvi._&ivi._&cmi.4cr;
				length Effect $ 12; 
				set &dvi._&ivi._&cmi.4cr;
				run;
				data &dvi._&ivi._&cmi.4cf;
				length Effect $ 12; 
				set &dvi._&ivi._&cmi.4cf;
				run;
				data &dvi._&ivi._&cmi.blp4c; * creating a data set that will add the random deviations to the fixed effect estimates ;
				merge &dvi._&ivi._&cmi.4cr(where=(Effect='Intercept') rename=(Estimate=ri4c&dvi._&ivi._&cmi.))
					  &dvi._&ivi._&cmi.4cr(where=(Effect='pmetvbr' ) rename=(Estimate=rs4c&dvi._&ivi._&cmi.));
				if _n_ = 1 then merge
				&dvi._&ivi._&cmi.4cf(where=(Effect='Intercept') rename=(Estimate=fi4c&dvi._&ivi._&cmi.))
				&dvi._&ivi._&cmi.4cf(where=(Effect='pmetvbr') rename=(Estimate=fs4c&dvi._&ivi._&cmi.));
				int4c&dvi._&ivi._&cmi. = fi4c&dvi._&ivi._&cmi. + ri4c&dvi._&ivi._&cmi.;
				slp4c&dvi._&ivi._&cmi. = fs4c&dvi._&ivi._&cmi. + rs4c&dvi._&ivi._&cmi.;
				idst = substr(Subject,3,5);
				id = input(idst,BEST12.);
				length id 4;
				label id ="subject id, child baseline"
					  int4c&dvi._&ivi._&cmi.="person intercept, model 4c etv-->&dvi._&ivi._&cmi."
					  slp4c&dvi._&ivi._&cmi.="person reactivity slope, model 4c etv-->&dvi._&ivi._&cmi.";
				keep id ri4c&dvi._&ivi._&cmi. fi4c&dvi._&ivi._&cmi. int4c&dvi._&ivi._&cmi. rs4c&dvi._&ivi._&cmi. fs4c&dvi._&ivi._&cmi. slp4c&dvi._&ivi._&cmi. ;
				run;
				proc sort data=&dvi._&ivi._&cmi.blp4c; by id;
				proc sort data=daywide; by id dlocaln2;
				data etv.daywide_model4; merge daywide &dvi._&ivi._&cmi.blp4c; by id;
				run; 
*/
			%end;
			data model4&dvi.; length Label $100; length modvar $25; set &wpcrei.; by depvar; run;

		%end;
		data model3&dvi.; set &wpcre.; by depvar; run;
		%let model12=&model12. model12&dvi.;
		%let model3=&model3. model3&dvi.;
		%let model4=&model4. model4&dvi.;
	%end;
	data etv.model&fn.12; set &model12.; run;
	data etv.model&fn.3; set &model3.; run;
	data etv.model&fn.4; set &model4.; run;
	proc print data=etv.model&fn.12;run;
	proc print data=etv.model&fn.3;run;
	proc print data=etv.model&fn.4;run;
%mend loopdv;

/*
change the following line to modify the 5 input fields: (name of results file, dependent variables, indipendent variables, binary moderators, continuous moderators). 
if any of last three fields are empty, it simply will skip the loop (and the ones nested below) associated with that field. 
the final results for Intercepts and Reactivity Slopes for each person models 3b&c and 4b&c are only temperarily saved in the work library. 
*/

* the following test the moderation effects for the 5 main outcomes: date=140319;
%loopdv(paper1_glimmix, pmcdsubbr pmdepbr pmir pmang pmhrbbr, 
	pmetvbr pmnx04, 
	strs_tot_cb strs_home_cb strs_school_cb strs_friend_cb strs_other_cb cladderrcb12 ccirc_iso_rb12 ccirc_iso_rb123, 
	strs_tot_c strs_home_c strs_school_c strs_friend_c strs_other_c cladderrc ccirc_iso_r);

* lagged models without moderation: date=140319;
%loopdv(lagtest_glimmix_l1, pmcdsubbr pmdepbr pmir pmang pmhrbbr amsq03b amsq04 amsq05 aman04 amde05 dailydepbrb dailyirb dailyangb amdx01b, 
	pmetvbrlag_1, , );

