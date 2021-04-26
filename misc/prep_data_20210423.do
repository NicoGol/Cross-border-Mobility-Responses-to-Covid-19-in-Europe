


********************************************************************************
*** Project: Cross-border Mobility Responses to Covid-19 inEurope: New Evidence from Facebook Data
*** Date: 	 20.04.2021
*** Contact: felix.stips@liser.lu
*** Stata Version: 16.0
*** Do-file description: prepare main dataset "fb_with_omegas.dta"
***				 
********************************************************************************

********************************************************************************

*** Instructions for running do-file: 
*** 	- Enter main path in global "path" below
***		- Setup your file folder structure with four subfolders "datain", "dataout", "output", "temp" in the "path" folder
***		- Make sure the following datasets are in the folder "datain" 
***			1. Gravity dataset: "release_1.0_2005_2016.csv" 
***				(from "https://usitc.gov/data/gravity/dgd.htm")
***			2. Facebook dataset: "movement_countries.csv" 
***				(from "https://raw.githubusercontent.com/pschaus/covidbe-opendata/master/static/csv/facebook/movement_countries.csv")
***			3. Our World in Data (Owid): "owid.csv"
***				(from "https://raw.githubusercontent.com/pschaus/covidbe-opendata/master/static/csv/owid.csv")
***			4. Oxford COVID-19 Government Response Tracker (OxCGRT) "OxCGRT_latest.csv"
***				(from "https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/OxCGRT_latest.csv")
***			5. Commuting Weights: Commuting_20200127.xlsx
***				(from own calculations based on Abel (2019) data)
***		- Make sure the following commands are installed
***			1. mdesc: ssc install mdesc
***			2. unique: ssc install unique
***			3. xfill: net from https://www.sealedenvelope.com/
***		- Note that "fb_with_omegas.dta" is the main data source used for analysis. This 
***			data drops bilateral dimension and keeps only sample corridors. Still, this 
***			outputs another dataset "fb_dyadic", which was used for one of the descriptive
***			statistics that is computed at country rather than corridor level. 
***				 
********************************************************************************
*** Clear

clear mata
clear all
set more off

********************************************************************************
*** Paths

global path "ENTER MAIN PATH HERE"
global datain "$path\datain"
global dataout "$path\dataout"
global output "$path\output"
global temp "$path\temp"

********************************************************************************

********************************************************************************

********************************************************************************

/*
************************
*** 1. Download data ***
************************

**********************************************************

* Facebook
import delimited "https://raw.githubusercontent.com/pschaus/covidbe-opendata/master/static/csv/facebook/movement_countries.csv"
export delimited using "$datain\movement_countries.csv", replace

* Owid
clear
import delimited "https://raw.githubusercontent.com/pschaus/covidbe-opendata/master/static/csv/owid.csv", clear
export delimited "$datain\owid.csv", replace

* OxCGRT
clear
import delimited "https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/OxCGRT_latest.csv"
export delimited using "$datain/OxCGRT.csv", replace
*/

**********************************************************

**********************
*** 2. Import data ***
**********************

**********************************************************

* Gravity
clear
import delimited "$datain\release_1.0_2005_2016.csv", clear 
save "$datain\gravity.dta", replace

* Facebook 
clear
import delimited "$datain\movement_countries.csv", clear 
save "$datain\movement_countries.dta", replace

* Owid
clear
import delimited "$datain\owid.csv", clear
save "$datain\owid.dta", replace

* OxCGRT
clear
import delimited "$datain\OxCGRT.csv", clear
save "$datain\OxCGRT.dta", replace

* Weights
clear
import excel "$datain\Commuting_20200127.xlsx", sheet("NewWeights") clear
save "$datain\Commuting_20200127.dta", replace

**********************************************************

**********************
*** 3. Clean data ***
**********************

**********************************************************

*** Gravity

use "$datain\gravity.dta", replace

* correct miskate in gravity data 
replace contiguity = 1 if country_o == "Greece" & country_d == "Bulgaria" | country_d == "Greece" & country_o == "Bulgaria" 

* keep newest version
keep if year == 2016															
foreach c in d o {
	replace iso3_`c' = "XKX" if country_`c' == "Kosovo"
	}
	
* keep variables	
keep country_d iso3_d dynamic_code_d country_o iso3_o dynamic_code_o contiguity hostility_level_o hostility_level_d distance common_language colony_of_destination_after45 colony_of_destination_current colony_of_destination_ever colony_of_origin_after45 colony_of_origin_current colony_of_origin_ever
foreach v in country iso3 dynamic_code hostility_level {
	rename `v'_o `v'_i
	rename `v'_d `v'_j
	
}
duplicates drop

* keep country sample	
#delimit ;
local countries `" "Austria" "Belgium" "Bosnia and Herzegovina" 
"Bulgaria" "Croatia" "Cyprus" "Czech Republic" "Denmark" "Estonia" "France"
"Finland" "France" "Germany" "Greece" "Hungary" "Ireland" "Italy" "Latvia" "Malta"
"Lithuania" "Luxembourg" "Netherlands" "Norway" "Poland" "Portugal" "Romania" 
"Serbia" "Slovakia" "Slovenia" "Spain" "Sweden" "Switzerland" "United Kingdom" "';
#delimit cr
foreach c in i j {
	foreach country in `countries' {
		qui count if country_`c' == "`country'"
		assert r(N) > 0
	}
	keep if country_`c' == "Austria" | country_`c' == "Belgium" | country_`c' == "Malta" ///
	| country_`c' == "Bosnia and Herzegovina" | country_`c' == "Bulgaria" | country_`c' == "Croatia" | country_`c' == "Cyprus" ///
	| country_`c' == "Czech Republic" | country_`c' == "Denmark" | country_`c' == "Estonia" | country_`c' == "France" ///
	| country_`c' == "Finland" | country_`c' == "France" | country_`c' == "Germany" | country_`c' == "Greece" ///
	| country_`c' == "Hungary" | country_`c' == "Ireland" | country_`c' == "Italy" | country_`c' == "Latvia" ///
	| country_`c' == "Lithuania" | country_`c' == "Luxembourg" | country_`c' == "Netherlands" ///
	| country_`c' == "Norway" | country_`c' == "Poland" | country_`c' == "Portugal" | country_`c' == "Romania" ///
	| country_`c' == "Serbia" | country_`c' == "Slovakia" | country_`c' == "Slovenia" ///
	| country_`c' == "Spain" | country_`c' == "Sweden" | country_`c' == "Switzerland" | country_`c' == "United Kingdom" 
}
drop if country_i == country_j

foreach var of varlist country_i country_j {
	qui unique `var'
	assert r(unique) == 32
}


* generate further variables
gen colony = .
replace colony = 1 if colony_of_origin_ever == 1 | colony_of_destination_ever == 1
replace colony = 0 if colony_of_origin_ever == 0 & colony_of_destination_ever == 0
qui count if colony == .
assert r(N) == 0
label var colony "colonial relationship ever"

gen eu = 1
foreach c in i j  {
	replace eu = 0 if country_`c' == "Bosnia and Herzegovina" | country_`c' == "Switzerland" | ///
	country_`c' == "Serbia" | country_`c' == "United Kingdom" | country_`c' == "Norway" 
	
	qui count if country_`c' == "Bosnia and Herzegovina"
	assert r(N) > 0
	qui count if country_`c' == "Switzerland"
	assert r(N) > 0
	qui count if country_`c' == "Serbia"
	assert r(N) > 0
	qui count if country_`c' == "United Kingdom"
	assert r(N) > 0
	qui count if country_`c' == "Norway"
	assert r(N) > 0
	
}
label var eu "1 if both countries eu"


foreach n in i j {
	qui count if country_`n' == "Greece"
	assert r(N) > 0	
}

save "$temp\gravdata", replace

**********************************************************

*** Owid

use "$datain\owid.dta", replace

drop continent
rename iso_code countrycode
rename location countryname

* rename vars
gen t = date(date, "YMD")
qui mdesc t
assert r(miss) == 0
label var t "day"
format t %td
drop if t < td(29feb2020)
drop if t > td(28feb2021)

rename new_deaths_smoothed_per_million new_deaths_smoothed_pm
label var new_deaths_smoothed_pm "New deaths smoothed per million"
rename new_cases_smoothed_per_million new_cases_smoothed_pm
label var new_cases_smoothed_pm "New cases smoothed per million"
rename weekly_icu_admissions_per_millio weekly_icu_admissions_pm
rename weekly_hosp_admissions_per_milli weekly_hosp_admissions_pm
rename new_tests_smoothed_per_thousand new_tests_smoothed_pt
label var new_tests_smoothed_pt "New tests per thousand"

* define sample 
replace countryname = "Czech Republic" if countryname == "Czechia"
	
	keep if  countryname == "Austria" | countryname== "Belgium" | countryname== "Malta" ///
	| countryname == "Bosnia and Herzegovina" | countryname== "Bulgaria" | countryname== "Croatia" | countryname== "Cyprus" ///
	| countryname== "Czech Republic" | countryname== "Denmark" | countryname== "Estonia" | countryname== "France" ///
	| countryname== "Finland" | countryname== "France" | countryname== "Germany" | countryname== "Greece" ///
	| countryname== "Hungary" | countryname== "Ireland" | countryname== "Italy" | countryname== "Latvia" ///
	| countryname== "Lithuania" | countryname== "Luxembourg"  | countryname== "Netherlands" ///
	| countryname== "Norway" | countryname== "Poland" | countryname== "Portugal" | countryname== "Romania" ///
	| countryname== "Serbia" | countryname== "Slovakia" | countryname== "Slovenia" ///
	| countryname== "Spain" | countryname== "Sweden" | countryname== "Switzerland" | countryname== "United Kingdom"

	
qui unique countryname
assert r(unique) == 32

* vars to keep
keep t countrycode countryname new_cases_per_million new_cases_smoothed_pm new_deaths_per_million new_deaths_smoothed_pm reproduction_rate population

	qui count if countryname == "Greece"
	assert r(N) > 0
	

foreach var of varlist new_deaths_per_million new_cases_per_million new_deaths_smoothed_pm new_cases_smoothed_pm {
	gen `var'_raw = `var'
	drop `var'
	qui sum `var'_raw
	gen `var' = (`var'_raw) / (`r(max)')	
	sum `var'
}
	
save "$temp\owid.dta", replace


**********************************************************

*** OxCGRT

use "$datain/OxCGRT.dta", replace

keep if jurisdiction == "NAT_TOTAL"			// drop regional legislation within countries
qui mdesc regionname 
assert r(percent) == 100
qui mdesc regioncode
assert r(percent) == 100
drop regionname regioncode


* Drop vars
drop e2_debtcontractrelief e1_incomesupport e1_flag e3_fiscalmeasures e4_internationalsupport h4_emergencyinvestmentinhealthca h5_investmentinvaccines h7_vaccinationpolicy h7_flag m1_wildcard h1_publicinformationcampaigns stringencyindex stringencyindexfordisplay stringencylegacyindex stringencylegacyindexfordisplay governmentresponseindex governmentresponseindexfordispla containmenthealthindex containmenthealthindexfordisplay economicsupportindex economicsupportindexfordisplay jurisdiction h1_flag confirmedcases confirmeddeaths

* Define date
tostring date, replace
gen t = date(date, "YMD")
mdesc t
assert r(miss) == 0
label var t "day"
format t %td
drop if t < td(29feb2020)
drop if t > td(28feb2021)
drop date	

* Fix countryname

foreach var of varlist countryname {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
	replace `var' = "Côte D'Ivoire" if `var' == "cÃ´te d'ivoire"
	replace `var' = upper(substr(`var',1,1)) + lower(substr(`var', 2, length(`var')))
	replace `var' = "Bosnia and Herzegovina" if `var' == "Bosnia and herzegovina"
	replace `var' = "United Kingdom" if `var' == "United kingdom"
	replace `var' = "Czech Republic" if `var' == "Czech republic"
	replace `var' = "Slovakia" if countryname == "Slovak republic"
	}


* Define sample
keep if  countryname == "Austria" | countryname== "Belgium" | countryname== "Malta" | countryname == "Bosnia and Herzegovina" ///
| countryname== "Bulgaria" | countryname== "Croatia" | countryname== "Cyprus" ///
| countryname== "Czech Republic" | countryname== "Denmark" | countryname== "Estonia" | countryname== "France" ///
| countryname== "Finland" | countryname== "France" | countryname== "Germany" | countryname== "Greece" ///
| countryname== "Hungary" | countryname== "Ireland" | countryname== "Italy" | countryname== "Latvia" ///
| countryname== "Lithuania" | countryname== "Luxembourg"  | countryname== "Netherlands" ///
| countryname== "Norway" | countryname== "Poland" | countryname== "Portugal" | countryname== "Romania" ///
| countryname== "Serbia" | countryname== "Slovakia" | countryname== "Slovenia" ///
| countryname== "Spain" | countryname== "Sweden" | countryname== "Switzerland" | countryname== "United Kingdom"

* shorten var names
rename c7_restrictionsoninternalmovemen c7_restr_move
rename c4_restrictionsongatherings c4_restr_gather
rename c8_internationaltravelcontrols c8_int_trvl_controls
rename c6_stayathomerequirements c6_stay_home
rename c3_cancelpublicevents c3_cancel_events
rename c5_closepublictransport c5_close_transp


* gen index like OxGCRT do
gen c1_schoolclosing_F = 1
gen c2_workplaceclosing_F = 1
gen c3_cancel_events_F = 1
gen c4_restr_gather_F = 1
gen c5_close_transp_F = 1
gen c6_stay_home_F = 1
gen c7_restr_move_F = 1
gen c8_int_trvl_controls_F = 0
gen h2_testingpolicy_F = 0
gen h3_contacttracing_F = 0
gen h6_facialcoverings_F = 1

rename c1_flag c1_schoolclosing_flag 
rename c2_flag c2_workplaceclosing_flag
rename c3_flag c3_cancel_events_flag
rename c4_flag c4_restr_gather_flag
rename c5_flag c5_close_transp_flag
rename c6_flag c6_stay_home_flag
rename c7_flag c7_restr_move_flag
rename h6_flag h6_facialcoverings_flag

gen c8_int_trvl_controls_flag = 0
gen h2_testingpolicy_flag = 0
gen h3_contacttracing_flag = 0 

global policyvars c1_schoolclosing c2_workplaceclosing c3_cancel_events c4_restr_gather c5_close_transp c6_stay_home c7_restr_move c8_int_trvl_controls h2_testingpolicy h3_contacttracing  h6_facialcoverings 

foreach var of varlist $policyvars {
    gen `var'_old = `var'
	qui sum `var'_old
	replace `var' = (`var'_old - 0.5 * (`var'_F - `var'_flag)) / `r(max)' 	// equation 2
	
	replace `var' = 0 if `var'_old == 0 									// index = 0 if policy = 0
	
	mdesc `var'
	scalar a = r(miss)
	mdesc `var'_old
	assert a == r(miss)
	
	replace `var' = 0 if `var' == .											// index = 0 if policy missing

	tab `var'
}

* drop vars
drop c1_schoolclosing_F c2_workplaceclosing_F c3_cancel_events_F c4_restr_gather_F ///
c5_close_transp_F c6_stay_home_F c7_restr_move_F c8_int_trvl_controls_F h2_testingpolicy_F ///
h3_contacttracing_F h6_facialcoverings_F ///
c8_int_trvl_controls_flag h2_testingpolicy_flag h3_contacttracing_flag c1_schoolclosing_flag ///
c2_workplaceclosing_flag c3_cancel_events_flag c4_restr_gather_flag c5_close_transp_flag ///
c6_stay_home_flag c7_restr_move_flag h6_facialcoverings_flag


save "$temp/OxCGRT.dta", replace


**********************************************************

*** Facebook

use "$datain\movement_countries.dta", replace

rename start_name country_i
rename end_name country_j

* fix country names
foreach var of varlist country_i country_j { // fix names
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
	replace `var' = "Côte D'Ivoire" if `var' == "cÃ´te d'ivoire"
	replace `var' = upper(substr(`var',1,1)) + lower(substr(`var', 2, length(`var')))
	replace `var' = "Bosnia and Herzegovina" if `var' == "Bosnia and herzegovina"
	replace `var' = "United Kingdom" if `var' == "United kingdom"
	replace `var' = "Czech Republic" if `var' == "Czech republic"
	}

* define sample	
foreach c in i j { // keep sample EU 27 + SUI, UK, NOR, BOS, SER
	foreach country in `countries' {
		qui count if country_`c' == "`country'"
		assert r(N) > 0
	}
	keep if  country_`c' == "Austria" | country_`c' == "Belgium" | country_`c' == "Malta" ///
	| country_`c' == "Bosnia and Herzegovina" | country_`c' == "Bulgaria" | country_`c' == "Croatia" | country_`c' == "Cyprus" ///
	| country_`c' == "Czech Republic" | country_`c' == "Denmark" | country_`c' == "Estonia" | country_`c' == "France" ///
	| country_`c' == "Finland" | country_`c' == "France" | country_`c' == "Germany" | country_`c' == "Greece" ///
	| country_`c' == "Hungary" | country_`c' == "Ireland" | country_`c' == "Italy" | country_`c' == "Latvia" ///
	| country_`c' == "Lithuania" | country_`c' == "Luxembourg"  | country_`c' == "Netherlands" ///
	| country_`c' == "Norway" | country_`c' == "Poland" | country_`c' == "Portugal" | country_`c' == "Romania" ///
	| country_`c' == "Serbia" | country_`c' == "Slovakia" | country_`c' == "Slovenia" ///
	| country_`c' == "Spain" | country_`c' == "Sweden" | country_`c' == "Switzerland" | country_`c' == "United Kingdom" 
}

foreach var of varlist country_i country_j {
	qui unique `var'
	assert r(unique) == 32
}

gen t = date(ds, "YMD")
qui mdesc t
assert r(miss) == 0
label var t "day"
format t %td
drop if t < td(29feb2020)
drop if t > td(28feb2021)


* fill gaps
qui count
scalar a = r(N)
fillin country_i country_j t
drop if country_i == country_j
drop _fillin

set obs `=_N+1' // add empty observation in March 27,
replace t = td(27mar2020) if _n == _N
replace country_i = "Austria" if _n == _N
replace country_j = "Germany" if _n == _N
replace travel_counts = 0 if _n == _N

set obs `=_N+1' // add empty observation in November 29
replace t = td(29nov2020) if _n == _N
replace country_i = "Austria" if _n == _N
replace country_j = "Germany" if _n == _N
replace travel_counts = 0 if _n == _N

set obs `=_N+1' // add empty observation in Decemebr 11
replace t = td(11dec2020) if _n == _N
replace country_i = "Austria" if _n == _N
replace country_j = "Germany" if _n == _N
replace travel_counts = 0 if _n == _N

set obs `=_N+1' // add empty observation in December 12, 
replace t = td(12dec2020) if _n == _N
replace country_i = "Austria" if _n == _N
replace country_j = "Germany" if _n == _N
replace travel_counts = 0 if _n == _N

set obs `=_N+1' // add empty observation in December 13
replace t = td(13dec2020) if _n == _N
replace country_i = "Austria" if _n == _N
replace country_j = "Germany" if _n == _N
replace travel_counts = 0 if _n == _N

* expand dataset
egen pair = group (country_i country_j) 
qui count
scalar a = r(N)
fillin pair t
qui count 
assert r(N) > a
xfill country_i country_j, i(pair)
qui count if country_i == "" | country_j == ""
assert r(N) == 0
drop _fillin pair


drop if country_i == country_j
replace travel_counts = 0 if travel_counts == .
rename travel_counts travel_counts_ij

* empty pair indicator
preserve 
collapse (sum) travel_counts_ij, by(country_i country_j)
qui count if travel_counts_ij == .
assert r(N) == 0
gen zero_pair = .
replace zero_pair = 1 if travel_counts_ij == 0
replace zero_pair = 0 if travel_counts_ij > 0 
qui count if zero_pair == .
assert r(N) == 0
drop travel_counts_ij
save "$temp/temp.dta", replace
restore
merge m:1 country_i country_j using "$temp/temp.dta"
qui count if _merge != 3
assert r(N) == 0
drop _merge

* opposite flows
save "$temp/fb.dta", replace 
rename travel_counts_ij travel_counts_ji // opposite flows
rename country_i temp
rename country_j country_i
rename temp country_j
save "$temp/temp.dta", replace

use "$temp/fb.dta", replace
merge 1:1 country_i country_j t using "$temp/temp.dta"
qui count if _merge != 3
assert r(N) == 0
drop _merge

* max traffic
egen max_travel = rowmax(travel_counts_ij travel_counts_ji)

foreach n in i j {
	qui count if country_`n' == "Greece"
	assert r(N) > 0
	
}

save "$temp/fb.dta", replace


**********************************************************

*** Weights

use "$datain\Commuting_20200127.dta", replace
drop J K L M N O P Q R S
rename A iso3_i
rename B iso3_j
rename C ij
rename D ji
rename E nameij
rename F wij_c
rename G wji_c
rename H wij_ac
rename I wji_ac

label var iso3_i "Origin i"
label var iso3_j "Destination j"
label var ij "Pair ij"
label var ji "Pair ji"
label var nameij "Name of pair ij"
label var wij_c "Weight ij commuting only"
label var wji_c "Weight ji commuting only"
label var wij_ac "Weight ij commuting + air"
label var wji_ac "Weight ji commuting + air "

drop if _n < 3
drop if _n > 48

foreach var of varlist wij_c wji_c wij_ac wji_ac {
	destring `var', replace
	
}

foreach var of varlist iso3_i iso3_j {
	replace `var' = strtrim(`var') 
}

foreach n in j {
	qui count if iso3_`n' == "GRC"
	assert r(N) > 0
	
}

save "$temp\Commuting.dta", replace

rename wij_c temp				// reverse everything
rename wji_c wij_c
rename temp wji_c

rename wij_ac temp
rename wji_ac wij_ac
rename temp wji_ac

rename ij temp
rename ji ij
rename temp ji

rename nameij nameji

rename iso3_i temp
rename iso3_j iso3_i
rename temp iso3_j
save "$temp\Commuting2.dta", replace


**********************************************************

**********************
*** 4. Merge data ***
**********************

**********************************************************

*** Merge OxCGRT with owid


use "$temp/OxCGRT.dta", replace
merge 1:1 countryname countrycode t using "$temp\owid.dta"
assert (_merge == 2) == 0
qui count if _merge == 1
assert r(N) == 37
assert (_merge == 1 & t > td(08mar2020)) == 0 // missing values only at the beginning of sample
drop _merge

rename countryname country
rename countrycode iso3

foreach var of varlist country {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
	replace `var' = "Côte D'Ivoire" if `var' == "cÃ´te d'ivoire"
	replace `var' = upper(substr(`var',1,1)) + lower(substr(`var', 2, length(`var')))
	replace `var' = "Bosnia and Herzegovina" if `var' == "Bosnia and herzegovina"
	replace `var' = "United Kingdom" if `var' == "United kingdom"
	replace `var' = "Czech Republic" if `var' == "Czech republic"
	}

qui count if country == "Greece"
assert r(N) > 0

* Gen origin and destination dataset
ds country* t, not
preserve
rename country country_j
foreach var of varlist `r(varlist)' {
	rename `var' `var'_j
	}
	
	
save "$temp/policy_destination.dta", replace

restore
rename country country_i
foreach var of varlist `r(varlist)' {
	rename `var' `var'_i
	}
	
save "$temp/policy_origin.dta", replace

**********************************************************

*** Merge everything on gravity data

* merge facebook
clear 
use "$temp\gravdata", replace
merge 1:m country_i country_j using "$temp/fb.dta", update
assert (_merge != 3) == 0
drop _merge

* merge policy origin
merge m:1 iso3_i country_i t using "$temp/policy_origin.dta" 
assert (_merge != 3) == 0
drop _merge

* merge policy destination
merge m:1 iso3_j country_j t using "$temp/policy_destination.dta" 
assert (_merge != 3) == 0
drop _merge

* merge commuting 
merge m:1 iso3_i iso3_j using "$temp/Commuting.dta", update 
assert (_merge == 2) == 0
gen tag1 = (zero_pair == 0 & contiguity == 1 & _merge < 3)
drop _merge 

* merge commuting opposite direction weights
merge m:1 iso3_i iso3_j using "$temp/Commuting2.dta", update 
assert (_merge == 2) == 0
gen tag2 = (zero_pair == 0 & contiguity == 1 & _merge < 3)
assert (tag1 == 1 & tag2 == 1) == 0 	// assert we cumutatively got whole sample 
drop tag1 tag2
drop _merge

* gen identifierts
egen id = group (country_i country_j)
label var id "unique origin x destination pair"
xtset id t
order t ds id country_i country_j

keep if zero_pair == 0
keep if contiguity == 1

foreach n in i j {
	qui count if country_`n' == "Greece"
	assert r(N) > 0
	
}

save "$dataout/fb_dyadic.dta", replace
export delimited using "$dataout/fb_dyadic.csv", replace


********************************************************************************

********************************
*** 5. Reduce dimensionality ***
********************************

********************************************************************************

drop  dynamic_code_j dynamic_code_i ds nameij nameji

gen pairname = cond(country_i < country_j, country_i + " " + country_j, country_j + " " + country_i)
egen strid = group(pairname)

duplicates drop strid t, force 


********************************************************************************

******************************
*** 6. Some more variables ***
******************************

********************************************************************************

xtset strid t

tssmooth ma max_travel_ma = max_travel, window (3 1 3)

#delimit ;
local controllist 
c1_schoolclosing c2_workplaceclosing c3_cancel_events c4_restr_gather c5_close_transp c6_stay_home c7_restr_move c8_int_trvl_controls h2_testingpolicy h3_contacttracing h6_facialcoverings  reproduction_rate;
#delimit cr

* Calculate 7 day moving average
foreach var in `controllist' {													
	foreach n in i j {
	    tssmooth ma `var'_ma_`n' = `var'_`n', window (3 1 3)
		label var `var'_ma_`n' "7 day moving average of `var'_`n'"	
	}
}

* Calculate travel growth
gen travel_0 = max_travel_ma if t == td(29feb2020)															
xfill travel_0, i(strid)
gen travel_grwth = ((max_travel_ma - travel_0)/ travel_0) * 100
drop travel_0


*** Create weighted policy variables

gen wijwji_ac = wij_ac - wji_ac 

local c8_int_trvl_controls_ma new_deaths_smoothed_pm new_cases_smoothed_pm 

foreach x in `n' { 								// symmetrical weighting scheme
	gen `x'_wji_ac = wijwji_ac * (`x'_j - `x'_i)				// see eq 5
}

foreach x in `n' {								// asymmetrical weighting scheme
	gen `x'_j_wji_ac = wij_ac * `x'_j + wji_ac * `x'_i 	// see eq 6
	gen `x'_i_wji_ac = wij_ac * `x'_i + wji_ac * `x'_j 
}


#delimit ;
local m 
c1_schoolclosing_ma c2_workplaceclosing_ma c3_cancel_events_ma c4_restr_gather_ma c5_close_transp_ma c6_stay_home_ma c7_restr_move_ma h2_testingpolicy_ma h3_contacttracing_ma h6_facialcoverings_ma;  
#delimit cr

foreach x in `m' { 								// symmetrical weighting scheme
	gen `x'_wji_ac = wijwji_ac * (`x'_j - `x'_i)				// see eq 5

}

foreach x in `m' {								// asymmetrical weighting scheme
	gen `x'_j_wji_ac = wij_ac * `x'_j + wji_ac * `x'_i 	// see eq 6
	gen `x'_i_wji_ac = wij_ac * `x'_i + wji_ac * `x'_j 
}



order t id strid pairname ij ji country_i iso3_i country_j iso3_j zero_pair contiguity travel_counts_ij travel_counts_ji max_travel max_travel_ma wij_c wji_c wij_ac wji_ac


save "$dataout/fb_with_omegas.dta", replace
export delimited using "$dataout/fb_with_omegas.csv", replace

********************************************************************************

******************************
*** 7. Erase datasets ***
******************************

********************************************************************************


erase "$temp/gravdata.dta"
erase "$temp/temp.dta"
erase "$temp/fb.dta"
erase "$temp/owid.dta"
erase "$temp/OxCGRT.dta"
erase "$temp/policy_destination.dta"
erase "$temp/policy_origin.dta"
erase "$temp/Commuting.dta"
erase "$temp/Commuting2.dta"



