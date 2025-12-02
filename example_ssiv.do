********************************************************************************
* Shift-Share IV Analysis - Example
* This script demonstrates how to use the ssiv command for
* Bartik-style instrumental variables estimation
* Author: Claude Code
* Date: 2025-12-02
********************************************************************************

clear all
set more off
set seed 12345

********************************************************************************
* Example 1: Simulated Immigration and Wage Growth Study
********************************************************************************

display as text _newline "{hline 80}"
display as text "Example 1: Immigration and Local Wage Growth"
display as text "{hline 80}"

* Create simulated data
* Locations: 100 cities
* Sectors: 10 industries
* Panel structure: location-sector pairs

set obs 1000

* Generate identifiers
gen location = mod(_n-1, 100) + 1
gen sector = mod(floor((_n-1)/100), 10) + 1

* Label variables
label var location "City ID"
label var sector "Industry ID"

* Generate initial employment shares (base year, e.g., 1980)
* These should sum to 1 within each location
gen emp_share_base = runiform(0.01, 0.20)
bysort location: egen total_share = total(emp_share_base)
replace emp_share_base = emp_share_base / total_share
drop total_share

label var emp_share_base "Employment share in base year"

* Generate sector-specific shocks (national growth rates)
* These vary by sector but not by location
bysort sector: gen sector_growth = rnormal(0.05, 0.03)
label var sector_growth "National sector growth rate"

* True effect of immigration on wages (for simulation)
local true_beta = -0.3

* Generate endogenous immigration share
* This is correlated with unobservables, creating endogeneity
gen unobservable = rnormal(0, 0.1)
gen immigrant_share = 0.1 + 0.5 * unobservable + rnormal(0, 0.05)
label var immigrant_share "Immigrant share (endogenous)"

* Generate outcome: wage growth
* This depends on immigration and unobservables
gen wage_growth = 0.03 + `true_beta' * immigrant_share + ///
    0.4 * unobservable + rnormal(0, 0.02)
label var wage_growth "Wage growth rate"

* Add some control variables
gen college_share = runiform(0.2, 0.6)
gen initial_wage = rnormal(50000, 10000)
label var college_share "Share with college degree"
label var initial_wage "Initial wage level"

display as text _newline "Data structure:"
describe location sector emp_share_base sector_growth immigrant_share wage_growth

********************************************************************************
* Run Shift-Share IV Analysis
********************************************************************************

display as text _newline "{hline 80}"
display as text "Running Shift-Share IV Estimation"
display as text "{hline 80}"

* Basic specification
ssiv wage_growth, ///
    shares(emp_share_base) ///
    shocks(sector_growth) ///
    location(location) ///
    sector(sector) ///
    endogenous(immigrant_share) ///
    cluster(location)

* Store results
estimates store ssiv_basic

* With control variables and first stage
display as text _newline "{hline 80}"
display as text "With Control Variables (showing first stage)"
display as text "{hline 80}"

ssiv wage_growth college_share, ///
    shares(emp_share_base) ///
    shocks(sector_growth) ///
    location(location) ///
    sector(sector) ///
    endogenous(immigrant_share) ///
    cluster(location) ///
    first ///
    saveinstrument(bartik_iv)

estimates store ssiv_controls

* Display comparison
display as text _newline "{hline 80}"
display as text "Comparison of Results"
display as text "{hline 80}"
estimates table ssiv_basic ssiv_controls, b(%7.4f) se stats(N N_locations first_stage_F)

********************************************************************************
* Example 2: China Trade Shock and Manufacturing Employment
********************************************************************************

display as text _newline _newline "{hline 80}"
display as text "Example 2: Trade Shock and Manufacturing Employment"
display as text "{hline 80}"

clear
set obs 800

* Generate identifiers: 80 regions, 10 manufacturing industries
gen region = mod(_n-1, 80) + 1
gen industry = mod(floor((_n-1)/80), 10) + 1

label var region "Region/commuting zone ID"
label var industry "Manufacturing industry ID"

* Initial industry shares (e.g., year 2000)
gen industry_share_2000 = runiform(0.05, 0.25)
bysort region: egen total_share = total(industry_share_2000)
replace industry_share_2000 = industry_share_2000 / total_share
drop total_share

label var industry_share_2000 "Industry employment share in 2000"

* China import growth by industry (the shock)
bysort industry: gen china_import_growth = runiform(0.1, 0.5)
label var china_import_growth "China import growth rate by industry"

* Generate endogenous import exposure
gen local_unobs = rnormal(0, 0.08)
gen import_exposure = 0.2 + 0.3 * local_unobs + rnormal(0, 0.04)
label var import_exposure "Local import exposure (endogenous)"

* Generate outcome: employment change
gen emp_change = -0.05 - 0.6 * import_exposure + ///
    0.5 * local_unobs + rnormal(0, 0.03)
label var emp_change "Manufacturing employment change"

* Controls
gen initial_manuf_share = runiform(0.15, 0.45)
gen college_grad_rate = runiform(0.15, 0.35)
label var initial_manuf_share "Initial manufacturing share"
label var college_grad_rate "College graduation rate"

* Run shift-share IV
display as text _newline "Running Trade Shock Analysis..."

ssiv emp_change initial_manuf_share college_grad_rate, ///
    shares(industry_share_2000) ///
    shocks(china_import_growth) ///
    location(region) ///
    sector(industry) ///
    endogenous(import_exposure) ///
    robust ///
    first

********************************************************************************
* Diagnostic Checks and Interpretation
********************************************************************************

display as text _newline "{hline 80}"
display as text "Key Diagnostics to Check:"
display as text "{hline 80}"
display as text "1. First-stage F-statistic > 10 (preferably > 16.4 for Stock-Yogo)"
display as text "2. Shares should sum to 1 (or close) within locations"
display as text "3. Shocks should vary by sector, not location"
display as text "4. Consider relevance and exogeneity assumptions"
display as text "{hline 80}"

display as text _newline "References:"
display as text "- Bartik (1991): Original shift-share approach"
display as text "- Goldsmith-Pinkham et al. (2020): Interpretation as share-weighted IV"
display as text "- Borusyak et al. (2022): Shock-level inference"
display as text "- Adão et al. (2019): Inference with many sectors"

********************************************************************************
* End of Example
********************************************************************************
