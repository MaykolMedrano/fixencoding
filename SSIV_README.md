# `ssiv`: Shift-Share Instrumental Variables Analysis for Stata

<p align="left">
  <img src="https://img.shields.io/badge/Stata-v14%2B-blue" alt="Stata Version">
  <img src="https://img.shields.io/badge/Release-v1.0-blue" alt="Current Release">
  <img src="https://img.shields.io/badge/Updated-December_2025-green" alt="Last Updated">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>

[Overview](#overview) | [Installation](#installation) | [Syntax](#syntax) | [Examples](#examples) | [Theory](#theoretical-background) | [References](#references)

---

## Overview

The `ssiv` command implements **shift-share instrumental variables** (IV) estimation in Stata, also known as the **Bartik instrument** approach. This is one of the most widely used quasi-experimental methods in economics for addressing endogeneity in location-level or regional analyses.

### What is Shift-Share IV?

Shift-share instruments are constructed by interacting:
- **Shares**: Initial local exposure to different sectors/industries (the "shift")
- **Shocks**: National or global sector-specific growth rates (the "share")

The resulting instrument predicts local outcomes based on national trends, weighted by local industrial composition.

### Key Applications

- **Labor Economics**: Immigration and local labor markets
- **International Trade**: China shock and manufacturing employment
- **Urban Economics**: Industry composition and city growth
- **Regional Economics**: Sectoral shocks and regional development

---

## Table of Contents

1. [Theoretical Background](#theoretical-background)
2. [Installation](#installation)
3. [Syntax](#syntax)
4. [Options](#options)
5. [Examples](#examples)
6. [Diagnostics and Validation](#diagnostics-and-validation)
7. [Recent Methodological Advances](#recent-methodological-advances)
8. [References](#references)
9. [License](#license)

---

## Theoretical Background

### The Bartik Instrument

The shift-share IV is constructed as:

```
Z_l = Σ_k (s_lk × g_k)
```

Where:
- `Z_l` = Instrument for location *l*
- `s_lk` = Share of sector *k* in location *l* (base period)
- `g_k` = Growth rate (shock) in sector *k* (excluding location *l*)

### Identification Strategy

**Key Assumptions:**

1. **Relevance**: The instrument must be correlated with the endogenous variable
   - Test: First-stage F-statistic > 10 (preferably > 16.4)

2. **Exogeneity**: Two interpretations (Goldsmith-Pinkham et al., 2020):
   - **Share-based**: Initial shares are as-good-as-random
   - **Shock-based**: Sectoral shocks are exogenous to local conditions

### Econometric Model

**First Stage:**
```
X_l = α + β·Z_l + γ·W_l + u_l
```

**Second Stage (IV):**
```
Y_l = α + δ·X̂_l + θ·W_l + ε_l
```

Where:
- `Y_l` = Outcome variable (e.g., wage growth)
- `X_l` = Endogenous variable (e.g., immigration)
- `Z_l` = Shift-share instrument
- `W_l` = Exogenous controls

---

## Installation

### Option 1: Manual Installation

1. Download the following files:
   - `ssiv.ado` (main program)
   - `ssiv.sthlp` (help file)

2. Copy them to your Stata personal ado directory:
   ```stata
   sysdir
   ```
   Look for the `PERSONAL` directory path.

3. Test the installation:
   ```stata
   which ssiv
   help ssiv
   ```

### Option 2: Direct Installation (if hosted on GitHub)

```stata
net install ssiv, from("https://raw.githubusercontent.com/username/repo/main/")
```

---

## Syntax

```stata
ssiv depvar [indepvars] [if] [in] [weight],
    shares(varname)
    shocks(varname)
    location(varname)
    sector(varname)
    endogenous(varlist)
    [exogenous(varlist)]
    [cluster(varname)]
    [robust]
    [first]
    [saveinstrument(name)]
    [baseyear(integer)]
```

### Required Options

| Option | Description |
|--------|-------------|
| `shares(varname)` | Variable containing initial shares s_lk |
| `shocks(varname)` | Variable containing sector-level shocks g_k |
| `location(varname)` | Location identifier (e.g., city, region) |
| `sector(varname)` | Sector/industry identifier |
| `endogenous(varlist)` | Endogenous variable(s) to instrument |

### Optional Options

| Option | Description |
|--------|-------------|
| `exogenous(varlist)` | Additional exogenous controls |
| `cluster(varname)` | Cluster standard errors (typically by location) |
| `robust` | Robust standard errors |
| `first` | Display detailed first-stage results |
| `saveinstrument(name)` | Save constructed IV as new variable |
| `baseyear(integer)` | Base year for documentation |

---

## Examples

### Example 1: Immigration and Wage Growth

```stata
* Load data
use immigration_data.dta, clear

* Basic shift-share IV estimation
ssiv wage_growth, ///
    shares(emp_share_1980) ///
    shocks(national_immigrant_growth) ///
    location(city) ///
    sector(industry) ///
    endogenous(immigrant_share) ///
    cluster(city)
```

**Interpretation**: Uses 1980 industry employment shares and national immigration growth rates by industry to instrument for local immigration.

### Example 2: China Trade Shock

```stata
* Load data
use china_shock.dta, clear

* Trade shock analysis with controls
ssiv emp_change manuf_share college_rate, ///
    shares(industry_share_2000) ///
    shocks(china_import_growth) ///
    location(commuting_zone) ///
    sector(industry_naics) ///
    endogenous(import_exposure) ///
    cluster(commuting_zone) ///
    first ///
    saveinstrument(bartik_iv)
```

**Interpretation**: Estimates the effect of Chinese import exposure on manufacturing employment using industry composition as of 2000.

### Example 3: Multiple Endogenous Variables

```stata
* Instrument for both immigration and trade exposure
ssiv wage_growth college_share, ///
    shares(emp_share_base) ///
    shocks(sector_shock) ///
    location(region) ///
    sector(industry) ///
    endogenous(immigrant_share trade_exposure) ///
    exogenous(initial_wage urban_dummy) ///
    robust ///
    first
```

---

## Diagnostics and Validation

### 1. First-Stage Strength

**Check the F-statistic:**
- **Weak IV**: F < 10
- **Acceptable**: F > 10
- **Strong IV**: F > 16.4 (Stock-Yogo critical value)

```stata
ssiv ..., first
* Check e(first_stage_F) in output
```

### 2. Relevance Tests

**Verify the instrument is correlated with endogenous variable:**
```stata
* After running ssiv
correlate bartik_iv immigrant_share
```

### 3. Balance Tests

**Test if shares are balanced on pre-treatment characteristics:**
```stata
reg pre_treatment_outcome share_1 share_2 share_3 ... share_K
test share_1 share_2 share_3 ... share_K
```

### 4. Overidentification Tests

**If using multiple instruments:**
```stata
ivregress 2sls Y (X = Z1 Z2), robust
estat overid
```

### 5. Data Structure Checks

**Verify shares sum to 1 within locations:**
```stata
bysort location: egen total_shares = total(emp_share)
summ total_shares
* Should be close to 1 for all locations
```

---

## Recent Methodological Advances

### Three Interpretations of Shift-Share IV

Recent literature provides different perspectives on shift-share identification:

#### 1. **Share-Weighted IV** (Goldsmith-Pinkham, Sorkin & Swift, 2020)
- Instrument is equivalent to using shares as multiple instruments
- Exogeneity requires shares to be as-good-as-random
- **Implication**: Test balance of shares on pre-trends

#### 2. **Shock-Level Inference** (Borusyak, Hull & Jaravel, 2022)
- Instrument inherits exogeneity from sectoral shocks
- Requires shocks to be quasi-random
- **Implication**: Can cluster standard errors at shock level

#### 3. **Exposure-Robust Inference** (Adão, Kolesár & Morales, 2019)
- Addresses correlation in exposure to common shocks
- Provides robust standard errors for many sectors
- **Implication**: Use specialized standard error corrections

### Practical Recommendations

1. **Report both interpretations**: Discuss share-based and shock-based identification
2. **Robustness checks**:
   - Vary the base year for shares
   - Exclude largest sectors
   - Use leave-one-out shocks (exclude own location)
3. **Transparency**: Report number of locations, sectors, and first-stage diagnostics

---

## Worked Example with Simulated Data

The repository includes `example_ssiv.do` which generates simulated data and demonstrates:

1. **Immigration study**: 100 cities, 10 industries
2. **Trade shock study**: 80 regions, 10 manufacturing sectors
3. **Diagnostic checks**: First-stage strength, relevance tests

To run:
```stata
do example_ssiv.do
```

---

## References

### Foundational Papers

**Bartik, T. J. (1991)**. *Who Benefits from State and Local Economic Development Policies?*
Kalamazoo, MI: W.E. Upjohn Institute for Employment Research.

### Methodological Advances

**Goldsmith-Pinkham, P., Sorkin, I., & Swift, H. (2020)**
"Bartik Instruments: What, When, Why, and How"
*American Economic Review*, 110(8), 2586-2624.
[https://doi.org/10.1257/aer.20181047](https://doi.org/10.1257/aer.20181047)

**Borusyak, K., Hull, P., & Jaravel, X. (2022)**
"Quasi-experimental shift-share research designs"
*Review of Economic Studies*, 89(1), 181-213.
[https://doi.org/10.1093/restud/rdab030](https://doi.org/10.1093/restud/rdab030)

**Adão, R., Kolesár, M., & Morales, E. (2019)**
"Shift-share designs: Theory and inference"
*Quarterly Journal of Economics*, 134(4), 1949-2010.
[https://doi.org/10.1093/qje/qjz025](https://doi.org/10.1093/qje/qjz025)

### Applications

**Card, D. (2001)**
"Immigrant inflows, native outflows, and the local labor market impacts of higher immigration"
*Journal of Labor Economics*, 19(1), 22-64.

**Autor, D., Dorn, D., & Hanson, G. (2013)**
"The China syndrome: Local labor market effects of import competition in the United States"
*American Economic Review*, 103(6), 2121-2168.

---

## Troubleshooting

### Common Issues

**1. Weak First Stage (F < 10)**
- **Solution**: Check relevance of shares and shocks
- Verify shares are from appropriate base period
- Ensure shocks vary sufficiently across sectors

**2. Shares Don't Sum to 1**
- **Solution**: Normalize shares within locations
```stata
bysort location: egen total = total(emp_share)
replace emp_share = emp_share / total
```

**3. Missing Values in Instrument**
- **Solution**: Ensure no missing values in shares or shocks
```stata
count if missing(emp_share) | missing(sector_growth)
```

**4. Standard Errors Too Large**
- **Solution**:
  - Check for sufficient variation in instrument
  - Consider whether clustering is too restrictive
  - Verify sample size is adequate

---

## Command Output Interpretation

### Sample Output

```
------------------------------------------------------------------------------
Shift-Share Instrumental Variables Estimation
------------------------------------------------------------------------------
Dependent variable: wage_growth
Endogenous variables: immigrant_share
Location identifier: city
Sector identifier: industry
------------------------------------------------------------------------------

Step 1: Constructing shift-share instrument...
  Observations: 1000
  Locations: 100
  Sectors: 10

Step 2: First stage regression...
  R-squared: 0.4521
  F-statistic on instrument: 82.45 (p = 0.0000)

Step 3: Second stage (IV) regression...
[Standard IV regression output]

------------------------------------------------------------------------------
Diagnostic Statistics:
  First-stage F-statistic: 82.45
  First-stage R-squared: 0.4521
  Standard errors: Clustered by city
------------------------------------------------------------------------------
```

### Key Elements to Check

1. **F-statistic > 10**: Indicates strong first stage
2. **R-squared**: Shows instrument relevance (typically 0.3-0.6)
3. **Number of observations, locations, sectors**: Verify expected counts
4. **Coefficient signs**: Should match economic theory

---

## Additional Resources

### Stata Commands

- `ivregress`: Built-in IV regression
- `ivreg2`: Extended IV regression (user-written)
- `weakiv`: Weak instrument tests (user-written)

### Online Resources

- [Goldsmith-Pinkham et al. Replication Package](https://github.com/paulgp/bartik-weight)
- [Borusyak et al. Replication Package](https://github.com/borusyak/shift-share)

---

## Citation

If you use this command in your research, please cite:

```
@software{ssiv2025,
  author = {Claude Code},
  title = {ssiv: Shift-Share Instrumental Variables for Stata},
  year = {2025},
  version = {1.0.0}
}
```

---

## License

This project is distributed under the MIT License.

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## Contact and Support

For bugs, questions, or feature requests, please open an issue on the GitHub repository.

## Version History

- **v1.0.0 (2025-12-02)**
  - Initial release
  - Basic shift-share IV estimation
  - Support for clustering and robust standard errors
  - Comprehensive diagnostics and first-stage reporting
