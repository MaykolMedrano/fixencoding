{smcl}
{* *! version 1.0.0  02dec2025}{...}
{viewerjumpto "Syntax" "ssiv##syntax"}{...}
{viewerjumpto "Description" "ssiv##description"}{...}
{viewerjumpto "Options" "ssiv##options"}{...}
{viewerjumpto "Examples" "ssiv##examples"}{...}
{viewerjumpto "Stored results" "ssiv##results"}{...}
{viewerjumpto "References" "ssiv##references"}{...}
{title:Title}

{p2colset 5 13 15 2}{...}
{p2col :{cmd:ssiv} {hline 2}}Shift-Share Instrumental Variables Analysis{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:ssiv}
{depvar} [{indepvars}]
{ifin}
{weight}
{cmd:,}
{opt shares(varname)}
{opt shocks(varname)}
{opt location(varname)}
{opt sector(varname)}
{opt endogenous(varlist)}
[{it:options}]


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opt shares(varname)}}variable containing initial shares (s_lk){p_end}
{synopt :{opt shocks(varname)}}variable containing sector-level shocks (g_k){p_end}
{synopt :{opt location(varname)}}location identifier{p_end}
{synopt :{opt sector(varname)}}sector/industry identifier{p_end}
{synopt :{opt endogenous(varlist)}}endogenous variables to be instrumented{p_end}

{syntab:Optional}
{synopt :{opt exogenous(varlist)}}additional exogenous control variables{p_end}
{synopt :{opt cluster(varname)}}cluster standard errors{p_end}
{synopt :{opt robust}}robust standard errors{p_end}
{synopt :{opt first}}display first-stage regression results{p_end}
{synopt :{opt saveinstrument(name)}}save constructed instrument as new variable{p_end}
{synopt :{opt baseyear(integer)}}base year for shares (documentation only){p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ssiv} implements shift-share instrumental variables estimation, also known as
the Bartik instrument approach. This method is widely used in economics to address
endogeneity in location-level outcomes.

{pstd}
The shift-share instrument is constructed as:

{p 8 12 2}
Z_l = Σ_k (s_lk × g_k)

{pstd}
where:

{p 8 12 2}
Z_l = shift-share instrument for location l{break}
s_lk = initial share of sector k in location l (base period){break}
g_k = national/global growth rate (shock) in sector k{break}

{pstd}
The command performs two-stage least squares (2SLS) estimation using the
constructed shift-share instrument.


{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opt shares(varname)} specifies the variable containing the initial shares.
These are typically the share of employment, output, or another measure in
sector k at location l in a base period.

{phang}
{opt shocks(varname)} specifies the variable containing sector-level shocks.
These are typically national or global growth rates for each sector, excluding
the location being studied (leave-out means).

{phang}
{opt location(varname)} specifies the variable identifying locations
(e.g., cities, regions, states).

{phang}
{opt sector(varname)} specifies the variable identifying sectors or industries.

{phang}
{opt endogenous(varlist)} specifies the endogenous variable(s) to be
instrumented with the shift-share IV.

{dlgtab:Optional}

{phang}
{opt exogenous(varlist)} specifies additional exogenous control variables to
include in both stages of the regression.

{phang}
{opt cluster(varname)} specifies clustering of standard errors by the specified
variable. Typically clustered at the location level.

{phang}
{opt robust} requests robust standard errors.

{phang}
{opt first} displays the first-stage regression results in detail.

{phang}
{opt saveinstrument(name)} saves the constructed shift-share instrument as a
new variable with the specified name.

{phang}
{opt baseyear(integer)} specifies the base year for documentation purposes.
This does not affect calculations.


{marker examples}{...}
{title:Examples}

{pstd}Setup: Employment growth and immigration{p_end}
{phang2}{cmd:. use immigrant_shocks.dta, clear}{p_end}

{pstd}Basic shift-share IV regression{p_end}
{phang2}{cmd:. ssiv wage_growth, shares(emp_share_1980) shocks(national_growth) location(city) sector(industry) endogenous(immigrant_share)}{p_end}

{pstd}With control variables and clustering{p_end}
{phang2}{cmd:. ssiv wage_growth education_avg, shares(emp_share_1980) shocks(national_growth) location(city) sector(industry) endogenous(immigrant_share) cluster(city)}{p_end}

{pstd}Show first stage and save instrument{p_end}
{phang2}{cmd:. ssiv employment_growth, shares(ind_share_2000) shocks(china_shock) location(region) sector(industry) endogenous(import_exposure) first saveinstrument(bartik_iv) cluster(region)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:ssiv} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_locations)}}number of locations{p_end}
{synopt:{cmd:e(N_sectors)}}number of sectors{p_end}
{synopt:{cmd:e(first_stage_F)}}first-stage F-statistic{p_end}
{synopt:{cmd:e(first_stage_r2)}}first-stage R-squared{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:ssiv}{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
{synopt:{cmd:e(endogenous)}}endogenous variable(s){p_end}
{synopt:{cmd:e(location_var)}}location identifier{p_end}
{synopt:{cmd:e(sector_var)}}sector identifier{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix{p_end}
{synopt:{cmd:e(first_stage_b)}}first-stage coefficients{p_end}


{marker references}{...}
{title:References}

{pstd}
Bartik, T. J. (1991). {it:Who Benefits from State and Local Economic Development Policies?}
Kalamazoo, MI: W.E. Upjohn Institute for Employment Research.

{pstd}
Goldsmith-Pinkham, P., Sorkin, I., & Swift, H. (2020).
Bartik Instruments: What, When, Why, and How.
{it:American Economic Review}, 110(8), 2586-2624.

{pstd}
Borusyak, K., Hull, P., & Jaravel, X. (2022).
Quasi-experimental shift-share research designs.
{it:Review of Economic Studies}, 89(1), 181-213.

{pstd}
Adão, R., Kolesár, M., & Morales, E. (2019).
Shift-share designs: Theory and inference.
{it:Quarterly Journal of Economics}, 134(4), 1949-2010.


{title:Author}

{pstd}
Claude Code{break}
December 2025


{title:Also see}

{psee}
Manual: {manlink R ivregress}

{psee}
Online: {helpb ivregress}, {helpb ivreg2} (if installed)
{p_end}
