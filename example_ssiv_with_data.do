********************************************************************************
* Ejemplos de Análisis Shift-Share IV con Datos Artificiales
* Este script demuestra el uso del comando ssiv con datasets de ejemplo
* Autor: Claude Code
* Fecha: 2025-12-02
********************************************************************************

clear all
set more off

********************************************************************************
* IMPORTANTE: Generar los datasets primero
********************************************************************************
* Antes de ejecutar este script, asegúrate de haber ejecutado:
* do create_example_data.do
********************************************************************************

********************************************************************************
* Ejemplo 1: Inmigración y Crecimiento Salarial
* Replicando el enfoque de Card (2001)
********************************************************************************

display as text _newline(2) "{hline 80}"
display as text "EJEMPLO 1: INMIGRACIÓN Y CRECIMIENTO SALARIAL (1990-2000)"
display as text "{hline 80}"

* Cargar datos
use "immigration_wages.dta", clear

* Descripción de los datos
display as text _newline "Estructura de los datos:"
describe city_id sector_id emp_share_1990 national_immig_growth ///
    immigrant_share_change wage_growth

display as text _newline "Primeras observaciones:"
list city_name sector_name emp_share_1990 national_immig_growth ///
    wage_growth in 1/10, sep(10) abbrev(20)

* Resumen de variables clave
display as text _newline "Resumen de variables clave:"
summ emp_share_1990 national_immig_growth immigrant_share_change ///
    wage_growth college_share

* Verificar que las participaciones suman a 1 dentro de cada ciudad
display as text _newline "Verificando que participaciones sumen a 1 por ciudad:"
bysort city_id: egen check_shares = total(emp_share_1990)
quietly summ check_shares
display as text "  Media de suma de participaciones: " as result %6.4f r(mean)
display as text "  Mínimo: " as result %6.4f r(min) as text "  Máximo: " as result %6.4f r(max)
drop check_shares

********************************************************************************
* 1A. Regresión OLS (sesgada por endogeneidad)
********************************************************************************

display as text _newline(2) "{hline 80}"
display as text "1A. Estimación OLS (para comparación - SESGADA)"
display as text "{hline 80}"

* OLS sin controles
regress wage_growth immigrant_share_change, robust
estimates store ols_basic

* OLS con controles
regress wage_growth immigrant_share_change college_share ///
    unemployment_1990, robust
estimates store ols_controls

display as text _newline "NOTA: OLS está sesgado porque immigrant_share_change está"
display as text "correlacionada con factores no observados de la ciudad."
display as text "El efecto verdadero (por diseño) es -0.25"

********************************************************************************
* 1B. Shift-Share IV (estimación insesgada)
********************************************************************************

display as text _newline(2) "{hline 80}"
display as text "1B. Estimación Shift-Share IV (INSESGADA)"
display as text "{hline 80}"

* Modelo básico sin controles
ssiv wage_growth, ///
    shares(emp_share_1990) ///
    shocks(national_immig_growth) ///
    location(city_id) ///
    sector(sector_id) ///
    endogenous(immigrant_share_change) ///
    robust ///
    first

estimates store ssiv_basic

* Modelo con controles
display as text _newline(2) "{hline 80}"
display as text "1C. Shift-Share IV con Variables de Control"
display as text "{hline 80}"

ssiv wage_growth college_share unemployment_1990, ///
    shares(emp_share_1990) ///
    shocks(national_immig_growth) ///
    location(city_id) ///
    sector(sector_id) ///
    endogenous(immigrant_share_change) ///
    cluster(city_id) ///
    saveinstrument(bartik_immigration) ///
    first

estimates store ssiv_controls

* Comparación de resultados
display as text _newline(2) "{hline 80}"
display as text "COMPARACIÓN OLS vs. SHIFT-SHARE IV"
display as text "{hline 80}"
estimates table ols_basic ols_controls ssiv_basic ssiv_controls, ///
    b(%7.4f) se(%7.4f) stats(N r2 first_stage_F) ///
    title("Comparación de Estimaciones") ///
    stfmt(%7.0f %7.4f %7.2f)

display as text _newline "INTERPRETACIÓN:"
display as text "- OLS sobreestima el efecto (sesgo hacia cero o positivo)"
display as text "- Shift-share IV recupera efecto cercano a -0.25 (efecto verdadero)"
display as text "- F-statistic > 16.4 indica instrumento fuerte"

********************************************************************************
* 1D. Análisis del Instrumento Bartik
********************************************************************************

display as text _newline(2) "{hline 80}"
display as text "1D. Análisis del Instrumento Shift-Share"
display as text "{hline 80}"

* Correlación entre instrumento y variable endógena
correlate bartik_immigration immigrant_share_change
display as text _newline "Correlación instrumento-endógena: " ///
    as result %6.4f r(rho)

* Distribución del instrumento
summ bartik_immigration, detail

* Primera etapa detallada
display as text _newline "Primera etapa (detallada):"
regress immigrant_share_change bartik_immigration college_share ///
    unemployment_1990, cluster(city_id)

* Test de balance: ¿Las participaciones están balanceadas?
display as text _newline(2) "{hline 80}"
display as text "Test de Balance de Participaciones Iniciales"
display as text "{hline 80}"

* Reshape para tener participaciones como variables
preserve
keep city_id sector_id emp_share_1990 wage_growth college_share
reshape wide emp_share_1990, i(city_id) j(sector_id)
regress wage_growth emp_share_19901-emp_share_199010
test emp_share_19901 emp_share_19902 emp_share_19903 emp_share_19904 ///
    emp_share_19905 emp_share_19906 emp_share_19907 emp_share_19908 ///
    emp_share_19909 emp_share_199010
display as text "Si p > 0.10, las participaciones están balanceadas"
restore

********************************************************************************
* Ejemplo 2: Shock Comercial con China
* Replicando Autor, Dorn & Hanson (2013)
********************************************************************************

display as text _newline(3) "{hline 80}"
display as text "EJEMPLO 2: SHOCK COMERCIAL CON CHINA (2000-2007)"
display as text "{hline 80}"

use "china_shock.dta", clear

* Descripción de los datos
display as text _newline "Estructura de los datos:"
describe czone_id industry_id industry_share_2000 china_import_growth ///
    import_exposure manuf_emp_change

display as text _newline "Primeras observaciones:"
list czone_name industry_name industry_share_2000 china_import_growth ///
    manuf_emp_change in 1/10, sep(10) abbrev(22)

* Resumen de variables
display as text _newline "Resumen de variables clave:"
summ industry_share_2000 china_import_growth import_exposure ///
    manuf_emp_change initial_manuf_share college_grad_rate

********************************************************************************
* 2A. OLS (sesgado)
********************************************************************************

display as text _newline(2) "{hline 80}"
display as text "2A. Estimación OLS (SESGADA)"
display as text "{hline 80}"

regress manuf_emp_change import_exposure initial_manuf_share ///
    college_grad_rate i.region, robust
estimates store china_ols

display as text _newline "NOTA: El efecto verdadero es -0.55"

********************************************************************************
* 2B. Shift-Share IV
********************************************************************************

display as text _newline(2) "{hline 80}"
display as text "2B. Estimación Shift-Share IV"
display as text "{hline 80}"

ssiv manuf_emp_change initial_manuf_share college_grad_rate, ///
    shares(industry_share_2000) ///
    shocks(china_import_growth) ///
    location(czone_id) ///
    sector(industry_id) ///
    endogenous(import_exposure) ///
    cluster(czone_id) ///
    saveinstrument(bartik_china) ///
    first

estimates store china_ssiv

* Comparación
display as text _newline(2) "{hline 80}"
display as text "COMPARACIÓN: OLS vs. SHIFT-SHARE IV (China Shock)"
display as text "{hline 80}"
estimates table china_ols china_ssiv, ///
    b(%7.4f) se(%7.4f) stats(N first_stage_F) ///
    stfmt(%7.0f %7.2f)

********************************************************************************
* 2C. Resultado alternativo: Cambio en salarios
********************************************************************************

display as text _newline(2) "{hline 80}"
display as text "2C. Efecto sobre Cambio en Salarios"
display as text "{hline 80}"

ssiv wage_change initial_manuf_share college_grad_rate, ///
    shares(industry_share_2000) ///
    shocks(china_import_growth) ///
    location(czone_id) ///
    sector(industry_id) ///
    endogenous(import_exposure) ///
    cluster(czone_id)

********************************************************************************
* 2D. Análisis de Sensibilidad
********************************************************************************

display as text _newline(2) "{hline 80}"
display as text "2D. Análisis de Sensibilidad"
display as text "{hline 80}"

* ¿El resultado es robusto a excluir las industrias más afectadas?
display as text _newline "Excluyendo industrias altamente expuestas (Textiles y Electrónica):"
ssiv manuf_emp_change initial_manuf_share college_grad_rate ///
    if !inlist(industry_id, 1, 2), ///
    shares(industry_share_2000) ///
    shocks(china_import_growth) ///
    location(czone_id) ///
    sector(industry_id) ///
    endogenous(import_exposure) ///
    cluster(czone_id)

* ¿Varía por región?
display as text _newline(2) "{hline 80}"
display as text "Análisis por Región"
display as text "{hline 80}"

forval r = 1/4 {
    local region_name : label region_lbl `r'
    display as text _newline "Región: `region_name'"

    quietly ssiv manuf_emp_change initial_manuf_share if region == `r', ///
        shares(industry_share_2000) ///
        shocks(china_import_growth) ///
        location(czone_id) ///
        sector(industry_id) ///
        endogenous(import_exposure) ///
        robust

    display as text "  Coeficiente: " as result %7.4f _b[import_exposure]
    display as text "  Primer stage F: " as result %7.2f e(first_stage_F)
}

********************************************************************************
* Ejemplo 3: Tutorial Simple
********************************************************************************

display as text _newline(3) "{hline 80}"
display as text "EJEMPLO 3: TUTORIAL SIMPLE"
display as text "{hline 80}"

use "simple_example.dta", clear

describe
list in 1/20

display as text _newline "Estimación básica:"
ssiv y, ///
    shares(share) ///
    shocks(shock) ///
    location(region) ///
    sector(sector) ///
    endogenous(x_endog) ///
    robust ///
    first ///
    saveinstrument(z_instrument)

display as text _newline "El efecto verdadero es -0.5"
display as text "El coeficiente estimado debería estar cerca de -0.5"

********************************************************************************
* Mejores Prácticas y Checklist
********************************************************************************

display as text _newline(3) "{hline 80}"
display as text "MEJORES PRÁCTICAS - CHECKLIST"
display as text "{hline 80}"
display as text ""
display as result "✓ Verificar que las participaciones sumen a 1 dentro de cada localidad"
display as result "✓ Verificar que los shocks varíen por sector, no por localidad"
display as result "✓ Reportar F-statistic de primera etapa (objetivo: > 16.4)"
display as result "✓ Usar errores estándar agrupados por localidad"
display as result "✓ Comparar OLS vs. IV para entender el sesgo"
display as result "✓ Realizar tests de balance de las participaciones"
display as result "✓ Análisis de sensibilidad (excluir sectores, subgrupos)"
display as result "✓ Reportar número de localidades y sectores"
display as result "✓ Discutir supuestos de identificación (shares vs. shocks)"
display as text ""
display as text "{hline 80}"

display as text _newline(2) "Para más detalles, ver:"
display as text "  - help ssiv"
display as text "  - SSIV_README.md"
display as text "  - Goldsmith-Pinkham, Sorkin & Swift (2020, AER)"
display as text "{hline 80}"

********************************************************************************
* Fin de los ejemplos
********************************************************************************
