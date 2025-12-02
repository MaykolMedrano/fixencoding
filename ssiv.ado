*! ssiv v1.0.0
*! Shift-Share Instrumental Variables Analysis
*! Implements Bartik-style shift-share IV estimation
*! Author: Claude Code
*! Date: 2025-12-02

capture program drop ssiv
program define ssiv, eclass
    version 14.0

    syntax varlist(min=1) [if] [in] [aw fw pw iw], ///
        SHares(varname) ///
        SHocks(varname) ///
        LOCation(varname) ///
        SEctor(varname) ///
        ENDogenous(varlist) ///
        [EXogenous(varlist)] ///
        [CLuster(varname)] ///
        [ROBust] ///
        [first] ///
        [saveinstrument(name)] ///
        [baseyear(integer 0)]

    marksample touse

    // Parse varlist
    gettoken depvar indepvars : varlist

    // Display header
    display as text _newline
    display as text "{hline 78}"
    display as text "Shift-Share Instrumental Variables Estimation"
    display as text "{hline 78}"
    display as text "Dependent variable: " as result "`depvar'"
    display as text "Endogenous variables: " as result "`endogenous'"
    display as text "Location identifier: " as result "`location'"
    display as text "Sector identifier: " as result "`sector'"
    display as text "{hline 78}"

    // Step 1: Construct the shift-share instrument
    display as text _newline "Step 1: Constructing shift-share instrument..."

    tempvar instrument

    // Sort data
    sort `location' `sector'

    // Calculate the shift-share IV: Z_l = sum_k (s_lk * g_k)
    // where s_lk = shares and g_k = shocks
    quietly {
        bysort `location': egen `instrument' = total(`shares' * `shocks') if `touse'

        // Count observations
        count if `touse'
        local N = r(N)

        // Count locations
        bysort `location': gen _temp_loc = (_n == 1) if `touse'
        count if _temp_loc == 1
        local N_locations = r(N)
        drop _temp_loc

        // Count sectors
        bysort `sector': gen _temp_sec = (_n == 1) if `touse'
        count if _temp_sec == 1
        local N_sectors = r(N)
        drop _temp_sec
    }

    display as text "  Observations: " as result `N'
    display as text "  Locations: " as result `N_locations'
    display as text "  Sectors: " as result `N_sectors'

    // Save instrument if requested
    if "`saveinstrument'" != "" {
        quietly gen `saveinstrument' = `instrument' if `touse'
        display as text "  Instrument saved as: " as result "`saveinstrument'"
    }

    // Step 2: First stage regression
    display as text _newline "Step 2: First stage regression..."
    display as text "{hline 78}"

    // Build first stage regression command
    local first_stage_vars "`instrument' `indepvars' `exogenous'"

    if "`cluster'" != "" {
        local vce_option "vce(cluster `cluster')"
    }
    else if "`robust'" != "" {
        local vce_option "robust"
    }

    if "`weight'" != "" {
        local weight_option "[`weight' `exp']"
    }

    // Run first stage
    quietly reg `endogenous' `first_stage_vars' if `touse' `weight_option', `vce_option'

    // Store first stage results
    matrix first_stage_coef = e(b)
    matrix first_stage_V = e(V)
    local first_stage_r2 = e(r2)
    local first_stage_N = e(N)

    // F-statistic for excluded instrument
    quietly test `instrument'
    local first_stage_F = r(F)
    local first_stage_p = r(p)

    if "`first'" != "" {
        display as text _newline "First Stage Results:"
        reg `endogenous' `first_stage_vars' if `touse' `weight_option', `vce_option'
    }
    else {
        display as text "  R-squared: " as result %6.4f `first_stage_r2'
        display as text "  F-statistic on instrument: " as result %8.2f `first_stage_F' ///
            as text " (p = " as result %6.4f `first_stage_p' as text ")"
    }

    // Warn if weak instrument
    if `first_stage_F' < 10 {
        display as error _newline "Warning: F-statistic < 10 suggests weak instrument"
        display as error "Stock-Yogo critical value (10% maximal IV size): ~16.4"
    }

    // Step 3: Second stage (IV regression)
    display as text _newline "Step 3: Second stage (IV) regression..."
    display as text "{hline 78}"

    // Build IV regression command
    local iv_indepvars "`indepvars' `exogenous'"

    ivregress 2sls `depvar' `iv_indepvars' (`endogenous' = `instrument') ///
        if `touse' `weight_option', `vce_option'

    // Store results
    ereturn local cmd "ssiv"
    ereturn local depvar "`depvar'"
    ereturn local endogenous "`endogenous'"
    ereturn local instrument_name "shift_share_IV"
    ereturn local location_var "`location'"
    ereturn local sector_var "`sector'"
    ereturn scalar N_locations = `N_locations'
    ereturn scalar N_sectors = `N_sectors'
    ereturn scalar first_stage_F = `first_stage_F'
    ereturn scalar first_stage_r2 = `first_stage_r2'
    ereturn matrix first_stage_b = first_stage_coef

    // Display diagnostic information
    display as text _newline "{hline 78}"
    display as text "Diagnostic Statistics:"
    display as text "  First-stage F-statistic: " as result %8.2f `first_stage_F'
    display as text "  First-stage R-squared: " as result %6.4f `first_stage_r2'

    if "`cluster'" != "" {
        display as text "  Standard errors: Clustered by `cluster'"
    }
    else if "`robust'" != "" {
        display as text "  Standard errors: Robust"
    }

    display as text "{hline 78}"

    // Display notes
    display as text _newline "Notes:"
    display as text "  - The shift-share IV is constructed as: Z_l = Σ_k (share_lk × shock_k)"
    display as text "  - Stock-Yogo weak IV test critical values (10% maximal IV size):"
    display as text "    One endogenous regressor: F > 16.38"
    display as text "  - See Goldsmith-Pinkham, Sorkin & Swift (2020) for interpretation"

end
