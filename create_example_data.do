********************************************************************************
* Script para Generar Datos Artificiales de Ejemplo
* Este script crea datasets en formato .dta para los ejemplos de ssiv
* Autor: Claude Code
* Fecha: 2025-12-02
********************************************************************************

clear all
set more off
set seed 98765

********************************************************************************
* Dataset 1: Inmigración y Crecimiento Salarial
* Basado en Card (2001) - Enfoque de ciudades y sectores industriales
********************************************************************************

display as text _newline "{hline 80}"
display as text "Generando: immigration_wages.dta"
display as text "{hline 80}"

clear
set obs 1500  // 50 ciudades × 30 observaciones por ciudad (sectores/años)

* Identificadores de localización (ciudades)
gen city_id = ceil(_n/30)
label var city_id "ID de Ciudad"

* Nombre de ciudades (ejemplos representativos)
gen str20 city_name = ""
replace city_name = "Nueva York" if city_id == 1
replace city_name = "Los Ángeles" if city_id == 2
replace city_name = "Chicago" if city_id == 3
replace city_name = "Houston" if city_id == 4
replace city_name = "Phoenix" if city_id == 5
replace city_name = "Miami" if city_id == 6
replace city_name = "San Francisco" if city_id == 7
replace city_name = "Boston" if city_id == 8
replace city_name = "Dallas" if city_id == 9
replace city_name = "Seattle" if city_id == 10
forval i = 11/50 {
    replace city_name = "Ciudad " + string(`i') if city_id == `i'
}
label var city_name "Nombre de Ciudad"

* Sectores industriales
gen sector_id = mod(_n-1, 10) + 1
label var sector_id "ID de Sector Industrial"

gen str30 sector_name = ""
replace sector_name = "Manufactura" if sector_id == 1
replace sector_name = "Construcción" if sector_id == 2
replace sector_name = "Comercio minorista" if sector_id == 3
replace sector_name = "Servicios profesionales" if sector_id == 4
replace sector_name = "Educación y salud" if sector_id == 5
replace sector_name = "Hotelería y restaurantes" if sector_id == 6
replace sector_name = "Transporte" if sector_id == 7
replace sector_name = "Servicios financieros" if sector_id == 8
replace sector_name = "Agricultura" if sector_id == 9
replace sector_name = "Otros servicios" if sector_id == 10
label var sector_name "Nombre de Sector"

* Participación del empleo por sector en 1990 (año base)
* Estas deben sumar aproximadamente 1 dentro de cada ciudad
gen emp_share_1990 = runiform(0.03, 0.15)
bysort city_id: egen total_share = total(emp_share_1990)
replace emp_share_1990 = emp_share_1990 / total_share
drop total_share

* Verificar que sumen a 1
bysort city_id: egen check_sum = total(emp_share_1990)
summ check_sum
drop check_sum

label var emp_share_1990 "Participación del empleo sectorial en 1990"
format emp_share_1990 %6.4f

* Tasa de crecimiento de inmigración nacional por sector (1990-2000)
* El "shock" - varía por sector, no por ciudad
bysort sector_id: gen national_immig_growth = rnormal(0.08, 0.04)
replace national_immig_growth = abs(national_immig_growth)  // Asegurar positivo

* Algunos sectores reciben más inmigración
replace national_immig_growth = national_immig_growth * 1.5 if sector_id == 2  // Construcción
replace national_immig_growth = national_immig_growth * 1.8 if sector_id == 6  // Hotelería
replace national_immig_growth = national_immig_growth * 1.3 if sector_id == 9  // Agricultura
replace national_immig_growth = national_immig_growth * 0.6 if sector_id == 8  // Finanzas

label var national_immig_growth "Crecimiento nacional de inmigración por sector"
format national_immig_growth %6.4f

* Variables de control a nivel de ciudad
* Estas son constantes dentro de cada ciudad
bysort city_id: gen temp = _n
gen college_share = runiform(0.20, 0.45) if temp == 1
bysort city_id: egen college_share_city = max(college_share)
drop college_share temp
rename college_share_city college_share
label var college_share "Proporción con educación universitaria"

bysort city_id: gen temp = _n
gen initial_wage = rnormal(45000, 12000) if temp == 1
bysort city_id: egen initial_wage_city = max(initial_wage)
drop initial_wage temp
rename initial_wage_city initial_wage
label var initial_wage "Salario inicial promedio (1990)"

bysort city_id: gen temp = _n
gen population_1990 = round(exp(rnormal(13, 0.8))) if temp == 1
bysort city_id: egen pop_city = max(population_1990)
drop population_1990 temp
rename pop_city population_1990
label var population_1990 "Población en 1990"

bysort city_id: gen temp = _n
gen unemployment_1990 = runiform(0.03, 0.08) if temp == 1
bysort city_id: egen unemp_city = max(unemployment_1990)
drop unemployment_1990 temp
rename unemp_city unemployment_1990
label var unemployment_1990 "Tasa de desempleo en 1990"

* Variable endógena: Participación de inmigrantes a nivel de ciudad (1990-2000)
* Esta está correlacionada con factores no observados
gen city_unobservable = rnormal(0, 0.08)
bysort city_id: egen city_effect = max(city_unobservable)
drop city_unobservable
rename city_effect city_unobs

* La inmigración local depende de factores no observados (endogeneidad)
bysort city_id: gen temp = _n
gen immigrant_share_change = 0.10 + 0.5 * city_unobs + ///
    0.3 * (college_share - 0.32) + rnormal(0, 0.03) if temp == 1
bysort city_id: egen immig_city = max(immigrant_share_change)
drop immigrant_share_change temp
rename immig_city immigrant_share_change
label var immigrant_share_change "Cambio en participación de inmigrantes (1990-2000)"

* Variable dependiente: Crecimiento salarial (1990-2000)
* El efecto verdadero de inmigración es -0.25 (por diseño)
local true_beta = -0.25

bysort city_id: gen temp = _n
gen wage_growth = 0.04 + `true_beta' * immigrant_share_change + ///
    0.35 * city_unobs + ///
    0.15 * (college_share - 0.32) + ///
    -0.02 * (unemployment_1990 - 0.055) + ///
    rnormal(0, 0.025) if temp == 1
bysort city_id: egen wage_city = max(wage_growth)
drop wage_growth temp
rename wage_city wage_growth
label var wage_growth "Tasa de crecimiento salarial (1990-2000)"

* Etiquetas de valores para sectores
label define sector_lbl 1 "Manufactura" 2 "Construcción" 3 "Comercio" ///
    4 "Servicios prof." 5 "Educación/salud" 6 "Hotelería" ///
    7 "Transporte" 8 "Finanzas" 9 "Agricultura" 10 "Otros"
label values sector_id sector_lbl

* Guardar el dataset
compress
order city_id city_name sector_id sector_name emp_share_1990 ///
    national_immig_growth immigrant_share_change wage_growth ///
    college_share initial_wage population_1990 unemployment_1990

notes: Dataset artificial de inmigración y salarios
notes: Estructura: 50 ciudades × 10 sectores = 500 obs ciudad-sector
notes: Año base: 1990, Periodo: 1990-2000
notes: Efecto verdadero de inmigración sobre salarios: -0.25
notes: Generado por: create_example_data.do
notes: Fecha: 2025-12-02

save "immigration_wages.dta", replace
display as result "  → Archivo guardado: immigration_wages.dta"
display as text "  → Observaciones: " as result _N
display as text "  → Ciudades: " as result 50
display as text "  → Sectores: " as result 10

********************************************************************************
* Dataset 2: Shock Comercial con China y Empleo Manufacturero
* Basado en Autor, Dorn & Hanson (2013)
********************************************************************************

display as text _newline "{hline 80}"
display as text "Generando: china_shock.dta"
display as text "{hline 80}"

clear
set obs 720  // 72 zonas de conmutación × 10 industrias manufactureras

* Zonas de conmutación (commuting zones)
gen czone_id = ceil(_n/10)
label var czone_id "ID de Zona de Conmutación"

gen str25 czone_name = ""
replace czone_name = "Rust Belt Norte" if czone_id == 1
replace czone_name = "Rust Belt Sur" if czone_id == 2
replace czone_name = "Costa Oeste" if czone_id == 3
replace czone_name = "Sunbelt" if czone_id == 4
replace czone_name = "Gran Lakes" if czone_id == 5
replace czone_name = "Noreste" if czone_id == 6
replace czone_name = "Sureste" if czone_id == 7
replace czone_name = "Midwest Rural" if czone_id == 8
forval i = 9/72 {
    replace czone_name = "Zona " + string(`i') if czone_id == `i'
}
label var czone_name "Nombre de Zona"

* Industrias manufactureras
gen industry_id = mod(_n-1, 10) + 1
label var industry_id "ID de Industria Manufacturera"

gen str35 industry_name = ""
replace industry_name = "Textiles y ropa" if industry_id == 1
replace industry_name = "Electrónica y computadoras" if industry_id == 2
replace industry_name = "Muebles y productos de madera" if industry_id == 3
replace industry_name = "Metales y productos metálicos" if industry_id == 4
replace industry_name = "Maquinaria industrial" if industry_id == 5
replace industry_name = "Plásticos y caucho" if industry_id == 6
replace industry_name = "Productos químicos" if industry_id == 7
replace industry_name = "Equipamiento de transporte" if industry_id == 8
replace industry_name = "Procesamiento de alimentos" if industry_id == 9
replace industry_name = "Productos diversos" if industry_id == 10
label var industry_name "Nombre de Industria"

* Participación industrial en el año 2000 (año base)
gen industry_share_2000 = runiform(0.04, 0.18)
bysort czone_id: egen total_share = total(industry_share_2000)
replace industry_share_2000 = industry_share_2000 / total_share
drop total_share
label var industry_share_2000 "Participación industrial en empleo (2000)"
format industry_share_2000 %6.4f

* Shock: Crecimiento de importaciones desde China por industria
* Varía por industria, no por zona
bysort industry_id: gen china_import_growth = runiform(0.15, 0.45)

* Algunas industrias fueron más afectadas por las importaciones chinas
replace china_import_growth = runiform(0.40, 0.70) if industry_id == 1  // Textiles
replace china_import_growth = runiform(0.35, 0.65) if industry_id == 2  // Electrónica
replace china_import_growth = runiform(0.30, 0.55) if industry_id == 3  // Muebles
replace china_import_growth = runiform(0.10, 0.25) if industry_id == 9  // Alimentos

label var china_import_growth "Crecimiento de importaciones de China por industria"
format china_import_growth %6.4f

* Variables de control a nivel de zona
bysort czone_id: gen temp = _n
gen manuf_share_2000 = runiform(0.12, 0.38) if temp == 1
bysort czone_id: egen manuf_zone = max(manuf_share_2000)
drop manuf_share_2000 temp
rename manuf_zone initial_manuf_share
label var initial_manuf_share "Participación manufactura en empleo (2000)"

bysort czone_id: gen temp = _n
gen college_grad_rate = runiform(0.15, 0.40) if temp == 1
bysort czone_id: egen college_zone = max(college_grad_rate)
drop college_grad_rate temp
rename college_zone college_grad_rate
label var college_grad_rate "Tasa de graduación universitaria"

bysort czone_id: gen temp = _n
gen avg_wage_2000 = rnormal(42000, 9000) if temp == 1
bysort czone_id: egen wage_zone = max(avg_wage_2000)
drop avg_wage_2000 temp
rename wage_zone avg_wage_2000
label var avg_wage_2000 "Salario promedio en 2000"

bysort czone_id: gen temp = _n
gen population_density = exp(rnormal(5, 1.2)) if temp == 1
bysort czone_id: egen dens_zone = max(population_density)
drop population_density temp
rename dens_zone population_density
label var population_density "Densidad poblacional (personas/km²)"

* Factor no observable a nivel de zona (genera endogeneidad)
gen zone_unobservable = rnormal(0, 0.06)
bysort czone_id: egen zone_effect = max(zone_unobservable)
drop zone_unobservable
rename zone_effect zone_unobs

* Variable endógena: Exposición a importaciones
* Está correlacionada con el efecto no observado de la zona
bysort czone_id: gen temp = _n
gen import_exposure = 0.25 + 0.35 * zone_unobs + ///
    0.4 * (initial_manuf_share - 0.25) + ///
    rnormal(0, 0.05) if temp == 1
bysort czone_id: egen import_zone = max(import_exposure)
drop import_exposure temp
rename import_zone import_exposure
label var import_exposure "Exposición a importaciones (2000-2007)"

* Variable dependiente: Cambio en empleo manufacturero (2000-2007)
* El efecto verdadero es -0.55
local true_effect = -0.55

bysort czone_id: gen temp = _n
gen emp_change = -0.04 + `true_effect' * import_exposure + ///
    0.45 * zone_unobs + ///
    0.20 * (college_grad_rate - 0.275) + ///
    -0.08 * (initial_manuf_share - 0.25) + ///
    rnormal(0, 0.035) if temp == 1
bysort czone_id: egen emp_zone = max(emp_change)
drop emp_change temp
rename emp_zone manuf_emp_change
label var manuf_emp_change "Cambio en empleo manufacturero (2000-2007)"

* Otras variables de resultado
bysort czone_id: gen temp = _n
gen wage_change = -0.02 + -0.35 * import_exposure + ///
    0.25 * zone_unobs + rnormal(0, 0.02) if temp == 1
bysort czone_id: egen wage_ch_zone = max(wage_change)
drop wage_change temp
rename wage_ch_zone wage_change
label var wage_change "Cambio en salarios (2000-2007)"

* Región geográfica
bysort czone_id: gen temp = _n
gen region = ceil(runiform() * 4) if temp == 1
bysort czone_id: egen region_zone = max(region)
drop region temp
rename region_zone region
label var region "Región geográfica"
label define region_lbl 1 "Noreste" 2 "Sur" 3 "Midwest" 4 "Oeste"
label values region region_lbl

* Etiquetas de valores para industrias
label define industry_lbl 1 "Textiles" 2 "Electrónica" 3 "Muebles" ///
    4 "Metales" 5 "Maquinaria" 6 "Plásticos" ///
    7 "Químicos" 8 "Transporte" 9 "Alimentos" 10 "Diversos"
label values industry_id industry_lbl

* Guardar el dataset
compress
order czone_id czone_name industry_id industry_name industry_share_2000 ///
    china_import_growth import_exposure manuf_emp_change wage_change ///
    initial_manuf_share college_grad_rate avg_wage_2000 region

notes: Dataset artificial del shock comercial con China
notes: Estructura: 72 zonas de conmutación × 10 industrias = 720 obs
notes: Periodo: 2000-2007
notes: Efecto verdadero de exposición sobre empleo: -0.55
notes: Generado por: create_example_data.do
notes: Fecha: 2025-12-02

save "china_shock.dta", replace
display as result "  → Archivo guardado: china_shock.dta"
display as text "  → Observaciones: " as result _N
display as text "  → Zonas de conmutación: " as result 72
display as text "  → Industrias: " as result 10

********************************************************************************
* Dataset 3: Ejemplo Simple para Tutorial
********************************************************************************

display as text _newline "{hline 80}"
display as text "Generando: simple_example.dta"
display as text "{hline 80}"

clear
set obs 300  // 30 regiones × 10 sectores

gen region = ceil(_n/10)
gen sector = mod(_n-1, 10) + 1

label var region "ID de Región"
label var sector "ID de Sector"

* Participaciones iniciales
gen share = runiform(0.05, 0.20)
bysort region: egen total = total(share)
replace share = share / total
drop total
label var share "Participación inicial del sector"

* Shocks sectoriales
bysort sector: gen shock = rnormal(0.05, 0.03)
label var shock "Shock sectorial"

* Variable endógena
gen region_effect = rnormal(0, 0.1)
bysort region: egen temp = max(region_effect)
drop region_effect
rename temp region_effect

bysort region: gen temp = _n
gen x_endog = 0.3 + 0.4 * region_effect + rnormal(0, 0.05) if temp == 1
bysort region: egen x_val = max(x_endog)
drop x_endog temp
rename x_val x_endog
label var x_endog "Variable endógena"

* Variable dependiente
bysort region: gen temp = _n
gen y = 2 + -0.5 * x_endog + 0.3 * region_effect + rnormal(0, 0.1) if temp == 1
bysort region: egen y_val = max(y)
drop y temp
rename y_val y
label var y "Variable dependiente"

compress
notes: Dataset simple para tutorial de ssiv
notes: 30 regiones × 10 sectores
notes: Efecto verdadero: -0.5

save "simple_example.dta", replace
display as result "  → Archivo guardado: simple_example.dta"

********************************************************************************
* Resumen
********************************************************************************

display as text _newline _newline "{hline 80}"
display as text "RESUMEN DE DATASETS GENERADOS"
display as text "{hline 80}"
display as text ""
display as result "1. immigration_wages.dta"
display as text "   - 50 ciudades × 10 sectores = 500 observaciones"
display as text "   - Periodo: 1990-2000"
display as text "   - Estudia inmigración y crecimiento salarial"
display as text ""
display as result "2. china_shock.dta"
display as text "   - 72 zonas × 10 industrias = 720 observaciones"
display as text "   - Periodo: 2000-2007"
display as text "   - Estudia importaciones chinas y empleo manufacturero"
display as text ""
display as result "3. simple_example.dta"
display as text "   - 30 regiones × 10 sectores = 300 observaciones"
display as text "   - Ejemplo simple para aprendizaje"
display as text ""
display as text "{hline 80}"
display as text "Para usar estos datos con ssiv, ver: example_ssiv_with_data.do"
display as text "{hline 80}"
