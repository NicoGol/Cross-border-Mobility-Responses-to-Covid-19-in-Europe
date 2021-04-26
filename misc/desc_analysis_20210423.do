

********************************************************************************
*** Project: Cross-border Mobility Responses to Covid-19 inEurope: New Evidence from Facebook Data
*** Date: 	 20.04.2021
*** Contact: felix.stips@liser.lu
*** Stata Version: 16.0
*** Do-file description: output Figure 1, Figure 2, Figure 4, and Figure A.2. 
***							Note that Figure A.1 was created directly in the Excel file "Commuting_20200127"
***							and Figure 3 was created in Python, part of the main analysis code file.
***	
********************************************************************************

********************************************************************************

*** Instructions for running do-file: 
*** 	- Enter main path in global "path" below
***		- Setup your file folder structure with four subfolders "datain", "dataout", "output", "temp" in the "path" folder
***		- Make sure the following datasets are in the folder "dataout" 
***			1. fb_with_omegas.dta
***			2. fb_dyadic.dta
***		- If you want to reproduce the font and layout, change "graph preference" settings in your Stata
***			1. Scheme: Cleanplots (although later I change it to plotplain), both are good to have ;)
***				--> net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
***				--> ssc install plotplain
***			2. Font: Luicida Console
***		- Make sure the following commands are installed
***			2. distinct: ssc install unique
***
***				 
********************************************************************************
*** Clear

clear mata
clear all
set more off

********************************************************************************
*** Paths

global path "ENTER PATH HERE"
global datain "$path\datain"
global dataout "$path\dataout"
global output "$path\output"
global temp "$path\temp"

********************************************************************************

*** Figure 1 : Aggregate Traffic
clear
use "$dataout/fb_with_omegas.dta", replace

* drop pairs that were also dropped in the main Python file (due to 75% missing rule)
qui distinct pairname																
scalar a = r(ndistinct)
drop if pairname == "Croatia Hungary" | pairname == "Finland Norway" | pairname == "Hungary Slovenia" // 
qui distinct pairname
assert r(ndistinct) == a - 3

preserve
	collapse (sum) max_travel_ma, by(t)
	sort t
	gen travel_grwth_exact = ((max_travel_ma - max_travel_ma[1])/ max_travel_ma[1]) * 100
	
	#delimit ;
	twoway 
		(line travel_grwth_exact t) ||
		(line travel_grwth t),
		xtitle("") 
		ytitle("{&Delta}({&Sigma}T{subscript:ij,t})") 
		graphregion(margin(2 7 2 2))
		ylab(0 "0%" -20 "-20%" -40 "-40%" -60 "-60%" -80 "-80%", angle(0))
		xlab(`=d(29feb2020)' `=d(01may2020)' `=d(01jul2020)' `=d(01sep2020)'
		`=d(01nov2020)' `=d(01jan2021)' `=d(28feb2021)', format(%td))
		legend(off)
		plotregion(style(none)) scheme(plotplain);
	#delimit cr
	
	graph export "$output/fig_1.pdf", as(pdf) replace

	
restore

*** Figure 2 : Corridor Traffic


	#delimit ;
	twoway 
		(line travel_grwth t if pairname == "Belgium Luxembourg") || 
		(line travel_grwth t if pairname == "France Luxembourg") || 
		(line travel_grwth t if pairname == "Germany Luxembourg") ,
		title(Panel A: Luxembourg)
		xtitle("") 
		graphregion(margin(0 0 0 0))
		ytitle("{&Delta}T{subscript:ij,t}") 
		ylab(100 "100%" 75 "75%" 50 "50%" 25 "25%" 0 "0%" -25 "-25%" -50 "-50%" -75 "-75%" -100 "-100%", angle(0))	
		xlab(`=d(29feb2020)' `=d(01may2020)' `=d(01jul2020)' `=d(01sep2020)' `=d(01nov2020)' `=d(01jan2021)' `=d(28feb2021)', format(%td) ang(30))
		legend(order(1 "Belgium" 2 "France" 3 "Germany"))
		plotregion(style(none)) scheme(plotplain)
		name(lux, replace) nodraw;
	#delimit cr
	
	
	#delimit ;
	twoway 
		(line travel_grwth t if pairname == "Austria Switzerland") || 
		(line travel_grwth t if pairname == "France Switzerland") || 
		(line travel_grwth t if pairname == "Italy Switzerland") || 
		(line travel_grwth t if pairname == "Germany Luxembourg") ,
		title(Panel B: Switzerland)
		xtitle("") 
		graphregion(margin(0 0 0 0))
		ytitle("{&Delta}T{subscript:ij,t}") 
		ylab(100 "100%" 75 "75%" 50 "50%" 25 "25%" 0 "0%" -25 "-25%" -50 "-50%" -75 "-75%" -100 "-100%", angle(0))
		xlab(`=d(29feb2020)' `=d(01may2020)' `=d(01jul2020)' `=d(01sep2020)' `=d(01nov2020)' `=d(01jan2021)' `=d(28feb2021)', format(%td) ang(30))
		legend(order(1 "Austria" 2 "France" 3 "Italy" 4 "Germany"))
		plotregion(style(none)) scheme(plotplain)
		name(switz, replace) nodraw;
	#delimit cr
	
	#delimit ;
	twoway 
		(line travel_grwth t if pairname == "Bulgaria Serbia") || 
		(line travel_grwth t if pairname == "Bosnia and Herzegovina Serbia") || 
		(line travel_grwth t if pairname == "Croatia Serbia") || 
		(line travel_grwth t if pairname == "Hungary Serbia") || 
		(line travel_grwth t if pairname == "Romania Serbia"), 
		title(Panel C: Serbia)
		graphregion(margin(0 0 0 0))
		ytitle("{&Delta}T{subscript:ij,t}") 
		xtitle("") 
		ylab(100 "100%" 75 "75%" 50 "50%" 25 "25%" 0 "0%" -25 "-25%" -50 "-50%" -75 "-75%" -100 "-100%", angle(0))
		xlab(`=d(29feb2020)' `=d(01may2020)' `=d(01jul2020)' `=d(01sep2020)' `=d(01nov2020)' `=d(01jan2021)' `=d(28feb2021)', format(%td) ang(30))
		legend(order(1 "Bulgaria" 2 "BiH" 3 "Croatia" 4 "Hungary" 5 "Romania"))
		plotregion(style(none)) scheme(plotplain)
		name(ser, replace) nodraw;
	#delimit cr
	
	#delimit ;
	twoway 
		(line travel_grwth t if pairname == "Austria Italy") || 
		(line travel_grwth t if pairname == "France Italy") || 
		(line travel_grwth t if pairname == "Italy Slovenia") || 
		(line travel_grwth t if pairname == "Italy Switzerland"), 
		ytitle("{&Delta}T{subscript:ij,t}") 
		title(Panel D: Italy)
		graphregion(margin(0 0 0 0))
		xtitle("") 
		ylab(100 "100%" 75 "75%" 50 "50%" 25 "25%" 0 "0%" -25 "-25%" -50 "-50%" -75 "-75%" -100 "-100%", angle(0))
		xlab(`=d(29feb2020)' `=d(01may2020)' `=d(01jul2020)' `=d(01sep2020)' `=d(01nov2020)' `=d(01jan2021)' `=d(28feb2021)', format(%td) ang(30))
		legend(order(1 "Austria" 2 "France" 3 "Slovenia" 4 "Switzerland"))
		plotregion(style(none)) scheme(plotplain) 
		name(italy, replace) nodraw;
	#delimit cr
	
	
	#delimit ;
	graph combine lux switz italy ser, 
	ysize(25) xsize(45) xcommon
	graphregion(color(white))
	imargin(zero)
	saving("$output/fig_2.pdf", replace);
	#delimit cr
	
	
*** Figure A.2 : Distribution of Weights

preserve
keep wij_ac wji_ac ij pairname 
duplicates drop
sort wij_ac
gen stid = _n
labmask stid, val(pairname)

#delimit ;
twoway 
	bar wij_ac stid,
		ytitle("{&omega}{subscript:i{&rarr}j}", orientation(horizontal) axis(2) size(small))
		yaxis(2)
		ylabel(,labsize(vsmall) angle(0)) ||
	bar wji_ac stid,
		yscale(reverse) 
		yaxis(1)
		ytitle("{&omega}{subscript:j{&rarr}i}", orientation(horizontal) axis(1) size(small)) 
		ylabel(,labsize(vsmall) angle(0))
	legend(order(1 "{&omega}{subscript:i{&rarr}j}" 2 "{&omega}{subscript:i{&rarr}j}")
		position(12) /*size(*.95) keygap(small)*/ just(center) rows(1)) 
	xlabel(1(1)45, labsize(vsmall) valuelabel angle(55))
	xtitle("")
	plotregion(style(none)) 
	scheme(plotplain);
#delimit cr

graph export "$output/fig_a2.pdf", as(pdf) replace
restore



*** Figure 4 : Correlation matrix

#delimit ;
global corrlist c1_schoolclosing_i c2_workplaceclosing_i c3_cancel_events_i 
c4_restr_gather_i c5_close_transp_i c6_stay_home_i c7_restr_move_i 
c8_int_trvl_controls_i h2_testingpolicy_i h3_contacttracing_i 
new_deaths_smoothed_pm_i new_cases_smoothed_pm_i;
#delimit cr


clear
use "$dataout/fb_dyadic.dta", replace

* drop pairs that were also dropped in the main Python file (due to 75% missing rule)
foreach var of varlist nameij nameji {

		drop if `var' == "Croatia Hungary" | `var' == "Finland Norway" | `var' == "Hungary Slovenia"
	
}

* Need to create variables that were created only later in prep_data dofile
tssmooth ma max_travel_ma = max_travel, window (3 1 3)	
bysort country_i t: egen tot_travel = total(max_travel_ma)

keep t country_i tot_travel $corrlist
duplicates drop

egen id = group (country_i)
xtset id t
gen travel_0 = tot_travel if t == td(29feb2020)								// calculate  travel growth							
xfill travel_0, i(id)
gen travel_grwth = ((tot_travel - travel_0)/ travel_0) * 100

corr $corrlist travel_grwth
matrix Corr = r(C)

#delimit ;
heatplot Corr,
lower 
values(mlabsize(*0.6) format(%9.2f))
xlabel("") 
ylabel(1 "C1 School closing" 2 "C2 Workplace closing" 3 "C3 Cancel events" 
4 "C4 Restrict gatherings" 5 "C5 close publ transport" 6 "C6 Stay at home" 
7 "C7 Internal movement" 8 "C8 Int travel controls" 9 "H2 Testing policy" 
10 "H3 Contact tracing" 11 "New cases smoothed" 12 "New deaths smoothed" 13 "Unilateral traffic growth", 
labsize(vsmall)) 
colors(plasma)
aspectratio(1) cuts(-1(0.2)1) 
plotregion(style(none))  
graphregion(margin(tiny))
scheme(s1color);
#delimit cr

graph export "$output/fig_4.pdf", as(pdf) replace























	/*
preserve
keep wij_ac wji_ac ij pairname 
duplicates drop
sort wij_ac
gen stid = _n
labmask stid, val(pairname)

#delimit ;
twoway 
	bar wij_ac stid,
		ytitle("{&omega}{subscript:i{&rarr}j}", orientation(horizontal) axis(2) size(small))
		yaxis(2)
		ylabel(,labsize(vsmall) angle(0)) ||
	bar wji_ac stid,
		yscale(reverse) 
		yaxis(1)
		ytitle("{&omega}{subscript:j{&rarr}i}", orientation(horizontal) axis(1) size(small)) 
		ylabel(,labsize(vsmall) angle(0))
	legend(order(1 "{&omega}{subscript:i{&rarr}j}" 2 "{&omega}{subscript:i{&rarr}j}")
		position(12) /*size(*.95) keygap(small)*/ just(center) rows(1)) 
	xlabel(1(1)45, labsize(vsmall) valuelabel angle(55))
	xtitle("")
	plotregion(style(none)) 
	scheme(plotplain);
#delimit cr

graph export normal.eps, as(eps) replace
writepsfrag normal.eps using normal.tex, replace
restore
	*/


drop max_travel_ma ln_max_travel_ma ln_max_travel_ma_1 max_travel				
egen max_travel = rowmax(travel_counts_ij travel_counts_ji)
tssmooth ma max_travel_ma = max_travel, window (3 1 3)

drop travel_grwth
gen travel_0 = max_travel_ma if t == td(29feb2020)								// gen (T-T0/T0)
xfill travel_0, i(strid)
gen travel_grwth = ((max_travel_ma - travel_0)/ travel_0) * 100
drop travel_0


*** Figure 1: Aggregate time series

preserve
	collapse (sum) max_travel_ma, by(t)
	sort t
	
	
	*gen travel_grwth = ln(max_travel_ma / max_travel_ma[1])
	gen travel_grwth_exact = ((max_travel_ma - max_travel_ma[1])/ max_travel_ma[1]) * 100
	

	#delimit ;
	twoway 
		(line travel_grwth_exact t) ||
		(line travel_grwth t),
		xtitle("") 
		ytitle("{&Delta}({&Sigma}T{subscript:ij,t})") 
		/*ytitle((T{subscript:ij,t}-T{subscript:ij,0})/T{subscript:ij,0}))*/
		graphregion(margin(2 7 2 2))
		ylab(0 "0%" -20 "-20%" -40 "-40%" -60 "-60%" -80 "-80%", angle(0))
		xlab(`=d(29feb2020)' `=d(01may2020)' `=d(01jul2020)' `=d(01sep2020)'
		`=d(01nov2020)' `=d(01jan2021)' `=d(28feb2021)', format(%td))
		legend(off)
		/*legend(order(1 "{&Delta} T{sub:ij,t}") position(0) bplacement(neast))*/
		plotregion(style(none)) scheme(plotplain);
	#delimit cr
	
	
restore



*** Figure 2: Individual time series


	#delimit ;
	twoway 
		(line travel_grwth t if pairname == "Belgium Luxembourg") || 
		(line travel_grwth t if pairname == "France Luxembourg") || 
		(line travel_grwth t if pairname == "Germany Luxembourg") ,
		title(Panel A: Luxembourg)
		xtitle("") 
		graphregion(margin(0 0 0 0))
		ytitle("{&Delta}T{subscript:ij,t}") 
		ylab(100 "100%" 75 "75%" 50 "50%" 25 "25%" 0 "0%" -25 "-25%" -50 "-50%" -75 "-75%" -100 "-100%", angle(0))	
		xlab(`=d(29feb2020)' `=d(01may2020)' `=d(01jul2020)' `=d(01sep2020)' `=d(01nov2020)' `=d(01jan2021)' `=d(28feb2021)', format(%td) ang(30))
		legend(order(1 "Belgium" 2 "France" 3 "Germany"))
		plotregion(style(none)) scheme(plotplain)
		name(lux, replace) ;
	#delimit cr
	
	
	#delimit ;
	twoway 
		(line travel_grwth t if pairname == "Austria Switzerland") || 
		(line travel_grwth t if pairname == "France Switzerland") || 
		(line travel_grwth t if pairname == "Italy Switzerland") || 
		(line travel_grwth t if pairname == "Germany Luxembourg") ,
		title(Panel B: Switzerland)
		xtitle("") 
		graphregion(margin(0 0 0 0))
		ytitle("{&Delta}T{subscript:ij,t}") 
		ylab(100 "100%" 75 "75%" 50 "50%" 25 "25%" 0 "0%" -25 "-25%" -50 "-50%" -75 "-75%" -100 "-100%", angle(0))
		xlab(`=d(29feb2020)' `=d(01may2020)' `=d(01jul2020)' `=d(01sep2020)' `=d(01nov2020)' `=d(01jan2021)' `=d(28feb2021)', format(%td) ang(30))
		legend(order(1 "Austria" 2 "France" 3 "Italy" 4 "Germany"))
		plotregion(style(none)) scheme(plotplain)
		name(switz, replace);
	#delimit cr
	
	#delimit ;
	twoway 
		(line travel_grwth t if pairname == "Bulgaria Serbia") || 
		(line travel_grwth t if pairname == "Bosnia and Herzegovina Serbia") || 
		(line travel_grwth t if pairname == "Croatia Serbia") || 
		(line travel_grwth t if pairname == "Hungary Serbia") || 
		(line travel_grwth t if pairname == "Romania Serbia"), 
		title(Panel C: Serbia)
		graphregion(margin(0 0 0 0))
		ytitle("{&Delta}T{subscript:ij,t}") 
		xtitle("") 
		ylab(100 "100%" 75 "75%" 50 "50%" 25 "25%" 0 "0%" -25 "-25%" -50 "-50%" -75 "-75%" -100 "-100%", angle(0))
		xlab(`=d(29feb2020)' `=d(01may2020)' `=d(01jul2020)' `=d(01sep2020)' `=d(01nov2020)' `=d(01jan2021)' `=d(28feb2021)', format(%td) ang(30))
		legend(order(1 "Bulgaria" 2 "BiH" 3 "Croatia" 4 "Hungary" 5 "Romania"))
		plotregion(style(none)) scheme(plotplain)
		name(ser, replace) nodraw;
	#delimit cr
	
	#delimit ;
	twoway 
		(line travel_grwth t if pairname == "Austria Italy") || 
		(line travel_grwth t if pairname == "France Italy") || 
		(line travel_grwth t if pairname == "Italy Slovenia") || 
		(line travel_grwth t if pairname == "Italy Switzerland"), 
		ytitle("{&Delta}T{subscript:ij,t}") 
		title(Panel D: Italy)
		graphregion(margin(0 0 0 0))
		xtitle("") 
		ylab(100 "100%" 75 "75%" 50 "50%" 25 "25%" 0 "0%" -25 "-25%" -50 "-50%" -75 "-75%" -100 "-100%", angle(0))
		xlab(`=d(29feb2020)' `=d(01may2020)' `=d(01jul2020)' `=d(01sep2020)' `=d(01nov2020)' `=d(01jan2021)' `=d(28feb2021)', format(%td) ang(30))
		legend(order(1 "Austria" 2 "France" 3 "Slovenia" 4 "Switzerland"))
		plotregion(style(none)) scheme(plotplain)
		name(italy, replace) nodraw;
	#delimit cr
	
	
	#delimit ;
	graph combine lux switz italy ser, 
	ysize(25) xsize(45) xcommon
	graphregion(color(white))
	imargin(zero)
	saving("$output2/corridors.png", replace);
	#delimit cr
	
	













global Regdep ln_max_travel_ma
global GLMdep max_travel_ma

#delimit ;


global UnI c1_schoolclosing_ma_i c2_workplaceclosing_ma_i c3_cancel_events_ma_i c4_restr_gather_ma_i c5_close_transp_ma_i c6_stay_home_ma_i c7_restr_move_ma_i c8_int_trvl_controls_ma_i
h1_inf_campgns_ma_i h2_testingpolicy_ma_i h3_contacttracing_ma_i h6_facialcoverings_ma_i
new_cases_smoothed_pm_i new_deaths_smoothed_pm_i; 


global UnJ c1_schoolclosing_ma_j c2_workplaceclosing_ma_j c3_cancel_events_ma_j 
c4_restr_gather_ma_j c5_close_transp_ma_j c6_stay_home_ma_j c7_restr_move_ma_j c8_int_trvl_controls_ma_j
h1_inf_campgns_ma_j h2_testingpolicy_ma_j h3_contacttracing_ma_j h6_facialcoverings_ma_j new_cases_smoothed_pm_j new_deaths_smoothed_pm_j ;

global unweightedControl $UnI $UnJ;

sum $unweightedControl;

global asymI c1_schoolclosing_ma_i_wji_ac c2_workplaceclosing_ma_i_wji_ac c3_cancel_events_ma_i_wji_ac
c4_restr_gather_ma_i_wji_ac c5_close_transp_ma_i_wji_ac c6_stay_home_ma_i_wji_ac c7_restr_move_ma_i_wji_ac c8_int_trvl_controls_ma_i_wji_ac
h1_inf_campgns_ma_i_wji_ac h2_testingpolicy_ma_i_wji_ac h3_contacttracing_ma_i_wji_ac h6_facialcoverings_ma_i_wji_ac new_cases_smoothed_pm_i_wji_ac new_deaths_smoothed_pm_i_wji_ac;

global asymJ c1_schoolclosing_ma_j_wji_ac c2_workplaceclosing_ma_j_wji_ac c3_cancel_events_ma_j_wji_ac 
c4_restr_gather_ma_j_wji_ac c5_close_transp_ma_j_wji_ac c6_stay_home_ma_j_wji_ac c7_restr_move_ma_j_wji_ac c8_int_trvl_controls_ma_j_wji_ac 
h1_inf_campgns_ma_j_wji_ac h2_testingpolicy_ma_j_wji_ac h3_contacttracing_ma_j_wji_ac  h6_facialcoverings_ma_j_wji_ac 
new_cases_smoothed_pm_j_wji_ac new_deaths_smoothed_pm_j_wji_ac;


global asymControl $asymI $asymJ;

sum $asymControl;

global symControl c1_schoolclosing_ma_wji_ac c2_workplaceclosing_ma_wji_ac c3_cancel_events_ma_wji_ac
c4_restr_gather_ma_wji_ac c5_close_transp_ma_wji_ac c6_stay_home_ma_wji_ac c7_restr_move_ma_wji_ac c8_int_trvl_controls_ma_wji_ac
h1_inf_campgns_ma_wji_ac h2_testingpolicy_ma_wji_ac h3_contacttracing_ma_wji_ac h6_facialcoverings_ma_wji_ac new_cases_smoothed_pm_wji_ac new_deaths_smoothed_pm_wji_ac;

sum $symControl;

#delimit cr

tabulate t, gen(_t_fe_)
tabulate strid, gen(_ij_fe_)


/// Linear Regression
reghdfe $Regdep $unweightedControl, absorb(strid t) vce(robust) noconstant resid
predict xbd, xbd
predict uhat, resid
gen expuhat = exp(uhat)
sum expuhat, meanonly
gen yhat = r(mean)*exp(xbd)

gen mape = abs(($GLMdep - yhat)/$GLMdep)
sum mape

qui sum $GLMdep 
scalar T = r(sum)
qui sum yhat 
scalar That = r(sum)
egen temp = rowmin($GLMdep yhat)
gen temp2 = 2*temp
qui sum temp2
scalar minT = r(sum)

scalar cpc = minT / (T + That)
drop temp temp2 
disp cpc



drop xbd uhat expuhat yhat mape
reghdfe $Regdep $symControl, absorb(strid t) vce(robust) noconstant  resid
predict xbd, xbd
predict uhat, resid
gen expuhat = exp(uhat)
sum expuhat, meanonly
gen yhat = r(mean)*exp(xbd)
gen mape = abs(($GLMdep - yhat)/$GLMdep)
sum mape

qui sum $GLMdep 
scalar T = r(sum)
qui sum yhat 
scalar That = r(sum)
egen temp = rowmin($GLMdep yhat)
gen temp2 = 2*temp
qui sum temp2
scalar minT = r(sum)

scalar cpc = minT / (T + That)
drop temp temp2 
disp cpc

drop xbd uhat expuhat yhat mape
reghdfe $Regdep $asymControl, absorb(strid t) vce(robust) noconstant resid  
predict xbd, xbd
predict uhat, resid
gen expuhat = exp(uhat)
sum expuhat, meanonly
gen yhat = r(mean)*exp(xbd)
gen mape = abs(($GLMdep - yhat)/$GLMdep)
sum mape

qui sum $GLMdep 
scalar T = r(sum)
qui sum yhat 
scalar That = r(sum)
egen temp = rowmin($GLMdep yhat)
gen temp2 = 2*temp
qui sum temp2
scalar minT = r(sum)

scalar cpc = minT / (T + That)
drop temp temp2 
disp cpc

hallo


hallo


ppmlhdfe $GLMdep $unweightedControl, absorb(strid t) vce(robust) noconstant 
estat ic
ppmlhdfe $GLMdep $symControl, absorb(strid t) vce(robust) noconstant 
estat ic
ppmlhdfe $GLMdep $asymControl, absorb(strid t) vce(robust) noconstant 
estat ic
coefplot, drop(_cons) xline(0) ///
	headings(c1_schoolclosing_ma_i_wji_ac = "{bf:Origin}" ///
	c1_schoolclosing_ma_j_wji_ac = "{bf:Destination}") ///
	coeflabels(c1_schoolclosing_ma_i_wji_ac = "School closing" ///
	c2_workplaceclosing_ma_i_wji_ac = "Workplace closing" ///
	c3_cancel_events_ma_i_wji_ac = "Cancel public events" ///
	c4_restr_gather_ma_i_wji_ac = "Restrictions on gatherings" ///
	c5_close_transp_ma_i_wji_ac = "Close public transport" ///
	c6_stay_home_ma_i_wji_ac = "Stay at home requirements" ///
	c7_restr_move_ma_i_wji_ac = "Restriction internal movement" ///
	c8_int_trvl_controls_ma_i_wji_ac = "International travel controls" ///
	h1_inf_campgns_ma_i_wji_ac = "Information campaigns" ///
	h2_testingpolicy_ma_i_wji_ac = "Testing policy" ///
	h3_contacttracing_ma_i_wji_ac = "Contract tracing" ///
	h6_facialcoverings_ma_i_wji_ac = "Facial coverings" ///
	new_cases_smoothed_pm_i_wji_ac = "New Covid cases" ///
	new_deaths_smoothed_pm_i_wji_ac = "New Covid deaths" ///
	c1_schoolclosing_ma_j_wji_ac = "School closing" ///
	c2_workplaceclosing_ma_j_wji_ac = "Workplace closing" ///
	c3_cancel_events_ma_j_wji_ac = "Cancel public events" ///
	c4_restr_gather_ma_j_wji_ac = "Restrictions on gatherings" ///
	c5_close_transp_ma_j_wji_ac = "Close public transport" ///
	c6_stay_home_ma_j_wji_ac = "Stay at home requirements" ///
	c7_restr_move_ma_j_wji_ac = "Restriction internal movement" ///
	c8_int_trvl_controls_ma_j_wji_ac = "International travel controls" ///
	h1_inf_campgns_ma_j_wji_ac = "Information campaigns" ///
	h2_testingpolicy_ma_j_wji_ac = "Testing policy" ///
	h3_contacttracing_ma_j_wji_ac = "Contract tracing" ///
	h6_facialcoverings_ma_j_wji_ac = "Facial coverings" ///
	new_cases_smoothed_pm_j_wji_ac = "New Covid cases" ///
	new_deaths_smoothed_pm_j_wji_ac = "New Covid deaths") ///
	plotregion(style(none)) scheme(plotplain)

hallo

estimates clear
ppmlhdfe $GLMdep $asymControl if t < td(01jul2020), absorb(strid t) vce(robust) noconstant  
estimates store A
ppmlhdfe $GLMdep $asymControl if t >= td(01jul2020) & t < td(01sep2020), absorb(strid t) vce(robust) noconstant  
estimates store B
ppmlhdfe $GLMdep $asymControl if t > td(01sep2020), absorb(strid t) vce(robust) noconstant  
estimates store C

coefplot A B C, drop(_cons) xline(0) ///
	headings(c1_schoolclosing_ma_i_wji_ac = "{bf:Origin}" ///
	c1_schoolclosing_ma_j_wji_ac = "{bf:Destination}") ///
	coeflabels(c1_schoolclosing_ma_i_wji_ac = "School closing" ///
	c2_workplaceclosing_ma_i_wji_ac = "Workplace closing" ///
	c3_cancel_events_ma_i_wji_ac = "Cancel public events" ///
	c4_restr_gather_ma_i_wji_ac = "Restrictions on gatherings" ///
	c5_close_transp_ma_i_wji_ac = "Close public transport" ///
	c6_stay_home_ma_i_wji_ac = "Stay at home requirements" ///
	c7_restr_move_ma_i_wji_ac = "Restriction internal movement" ///
	c8_int_trvl_controls_ma_i_wji_ac = "International travel controls" ///
	h1_inf_campgns_ma_i_wji_ac = "Information campaigns" ///
	h2_testingpolicy_ma_i_wji_ac = "Testing policy" ///
	h3_contacttracing_ma_i_wji_ac = "Contract tracing" ///
	h6_facialcoverings_ma_i_wji_ac = "Facial coverings" ///
	new_cases_smoothed_pm_i_wji_ac = "New Covid cases" ///
	new_deaths_smoothed_pm_i_wji_ac = "New Covid deaths" ///
	c1_schoolclosing_ma_j_wji_ac = "School closing" ///
	c2_workplaceclosing_ma_j_wji_ac = "Workplace closing" ///
	c3_cancel_events_ma_j_wji_ac = "Cancel public events" ///
	c4_restr_gather_ma_j_wji_ac = "Restrictions on gatherings" ///
	c5_close_transp_ma_j_wji_ac = "Close public transport" ///
	c6_stay_home_ma_j_wji_ac = "Stay at home requirements" ///
	c7_restr_move_ma_j_wji_ac = "Restriction internal movement" ///
	c8_int_trvl_controls_ma_j_wji_ac = "International travel controls" ///
	h1_inf_campgns_ma_j_wji_ac = "Information campaigns" ///
	h2_testingpolicy_ma_j_wji_ac = "Testing policy" ///
	h3_contacttracing_ma_j_wji_ac = "Contract tracing" ///
	h6_facialcoverings_ma_j_wji_ac = "Facial coverings" ///
	new_cases_smoothed_pm_j_wji_ac = "New Covid cases" ///
	new_deaths_smoothed_pm_j_wji_ac = "New Covid deaths") ///
	legend(order(2 "Mar-Jun" 4 "Jul-Aug" 6 "Sep-Nov")) ///
	plotregion(style(none)) scheme(plotplain)
graph export "$output2/coefplot_season.png", as(png) replace

 

ppml $GLMdep $asymControl _t_fe_* _ij_fe_*, noconstant

estat ic
predict ghat
predict resid, pearson

scatter resid ghat || ///
  lowess resid ghat, ///
  yline(0, lcolor(navy)) ///
  legend(off) ///
  title(Residual Plot) ///
  xtitle(Predicted on green in regulation proportion) ///
  ytitle(Residuals (Pearson))

  gen resid_sqr=resid^2
sum resid_sqr

scatter resid_sqr ghat ///
  || lowess resid_sqr ghat, ///
  yline(`r(mean)', lcolor(black)) ///
  title(Residual variation plot) ///
  ytitle(Squared residuals (Pearson)) ///
  xtitle(Predicted on green in regulation proportion) ///
  legend(off)
  
done












hallo


*** Figure 2: Individual time series


	#delimit ;
	twoway 
		(line travel_grwth t if pairname == "Belgium Luxembourg") || 
		(line travel_grwth t if pairname == "France Luxembourg") || 
		(line travel_grwth t if pairname == "Germany Luxembourg") ,
		title(Luxembourg)
		xtitle("") ytitle("") 
		/*ytitle(ln(T{subscript:ij,t}/T{subscript:ij,0}))*/
		ylab(, angle(0))
		legend(order(1 "Belgium" 2 "France" 3 "Germany"))
		plotregion(style(none)) scheme(plotplain)
		name(lux, replace) nodraw;
	#delimit cr
	
	#delimit ;
	twoway 
		(line travel_grwth t if pairname == "Austria Switzerland") || 
		(line travel_grwth t if pairname == "France Switzerland") || 
		(line travel_grwth t if pairname == "Italy Switzerland") || 
		(line travel_grwth t if pairname == "Germany Luxembourg") ,
		title(Switzerland)
		xtitle("") ytitle("") 
		/*ytitle(ln(T{subscript:ij,t}/T{subscript:ij,0}))*/
		ylab(, angle(0))
		legend(order(1 "Austria" 2 "France" 3 "Italy" 4 "Germany"))
		plotregion(style(none)) scheme(plotplain)
		name(switz, replace) nodraw;
	#delimit cr
	
	#delimit ;
	twoway 
		(line travel_grwth t if pairname == "Bulgaria Serbia") || 
		(line travel_grwth t if pairname == "Bosnia and Herzegovina Serbia") || 
		(line travel_grwth t if pairname == "Croatia Serbia") || 
		(line travel_grwth t if pairname == "Hungary Serbia") || 
		(line travel_grwth t if pairname == "Romania Serbia"), 
		title(Serbia)
		xtitle("") ytitle("") 
		/*ytitle(ln(T{subscript:ij,t}/T{subscript:ij,0}))*/
		ylab(, angle(0))
		legend(order(1 "Bulgaria" 2 "BiH" 3 "Croatia" 4 "Hungary" 5 "Romania"))
		plotregion(style(none)) scheme(plotplain)
		name(ser, replace) nodraw;
	#delimit cr
	
	#delimit ;
	twoway 
		(line travel_grwth t if pairname == "Austria Italy") || 
		(line travel_grwth t if pairname == "France Italy") || 
		(line travel_grwth t if pairname == "Italy Slovenia") || 
		(line travel_grwth t if pairname == "Italy Switzerland"), 
		title(Italy)
		xtitle("") ytitle("") 
		/*ytitle(ln(T{subscript:ij,t}/T{subscript:ij,0}))*/
		ylab(, angle(0))
		legend(order(1 "Austria" 2 "France" 3 "Slovenia" 4 "Switzerland"))
		plotregion(style(none)) scheme(plotplain)
		name(italy, replace) nodraw;
	#delimit cr
	
	
	#delimit ;
	graph combine lux switz italy ser, 
	ysize(25) xsize(45) xcommon
	graphregion(color(white))
	saving("$output2/corridors.png", replace);
	#delimit cr