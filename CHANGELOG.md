# Registro de Cambios - ssiv

## [1.0.1] - 2025-12-02

### 🐛 Correcciones de Bugs

#### Críticos
- **Conflictos de nombres de variables temporales**: Ahora usa `tempvar` en lugar de nombres fijos `_temp_loc` y `_temp_sec` para evitar conflictos con datasets del usuario
- **Múltiples variables endógenas sin soporte**: Agregada validación que da error claro cuando se intenta usar múltiples variables endógenas (no soportado en v1.0)

#### Importantes
- **Validación de variación del instrumento**: Ahora verifica que el instrumento shift-share tenga variación antes de proceder. Muestra mensaje de error claro si no hay variación.
- **Saveinstrument mejorado**: Agregado `capture drop` antes de guardar instrumento para permitir re-ejecución del comando

#### Menores
- **Ordenamiento mejorado en bysort**: Especificado orden secundario `(sector)` en construcción del instrumento para mayor reproducibilidad

### ✨ Nuevas Características

#### Datasets de Ejemplo
- **`immigration_wages.dta`**: Dataset artificial de inmigración y salarios (50 ciudades × 10 sectores)
  - Basado en Card (2001)
  - Periodo 1990-2000
  - Efecto verdadero conocido: -0.25

- **`china_shock.dta`**: Dataset artificial del shock comercial con China (72 zonas × 10 industrias)
  - Basado en Autor, Dorn & Hanson (2013)
  - Periodo 2000-2007
  - Efecto verdadero conocido: -0.55

- **`simple_example.dta`**: Dataset simple para aprendizaje (30 regiones × 10 sectores)
  - Ejemplo didáctico básico
  - Efecto verdadero: -0.5

#### Scripts de Ejemplo Mejorados
- **`create_example_data.do`**: Script completo para generar los tres datasets de ejemplo
  - Documentación detallada de la estructura de datos
  - Variables etiquetadas en español
  - Notas integradas en los datasets

- **`example_ssiv_with_data.do`**: Tutorial completo con análisis paso a paso
  - Comparaciones OLS vs. Shift-Share IV
  - Análisis detallado de instrumentos
  - Tests de balance de participaciones
  - Análisis de sensibilidad y robustez
  - Análisis por subgrupos
  - Checklist de mejores prácticas

#### Documentación
- **`BUGFIXES.md`**: Documentación detallada de todos los bugs corregidos
  - Descripción del problema
  - Código antes/después
  - Impacto y severidad
  - Tests realizados

- **`CHANGELOG.md`**: Este archivo - registro de cambios por versión

### 📝 Mejoras en Documentación

- Actualizado `ssiv.pkg` con información de la nueva versión
- Ejemplos más realistas y educativos
- Mejor cobertura de casos de uso comunes
- Interpretación de resultados incluida

### 🧪 Testing

- Verificado funcionamiento con datasets de ejemplo
- Testeado manejo de errores mejorado
- Validado compatibilidad con Stata 14+

---

## [1.0.0] - 2025-12-02

### ✨ Versión Inicial

#### Características Principales
- Implementación completa de shift-share IV (Bartik)
- Construcción automática de instrumentos: Z_l = Σ_k (share_lk × shock_k)
- Estimación 2SLS con `ivregress`
- Diagnósticos de primera etapa
- F-statistic y tests de instrumento débil
- Warnings automáticos (F < 10)
- Soporte para clustering y errores estándar robustos
- Opción para mostrar primera etapa detallada
- Guardado opcional del instrumento construido

#### Sintaxis
```stata
ssiv depvar [indepvars], ///
    shares(varname) ///
    shocks(varname) ///
    location(varname) ///
    sector(varname) ///
    endogenous(varlist) ///
    [options]
```

#### Opciones Disponibles
- `exogenous()`: Variables de control exógenas
- `cluster()`: Clustering de errores estándar
- `robust`: Errores estándar robustos
- `first`: Mostrar primera etapa detallada
- `saveinstrument()`: Guardar instrumento como variable
- `baseyear()`: Año base (documentación)

#### Resultados Almacenados
- Escalares: N, N_locations, N_sectors, first_stage_F, first_stage_r2
- Macros: cmd, depvar, endogenous, location_var, sector_var
- Matrices: b, V, first_stage_b

#### Documentación Inicial
- `ssiv.ado`: Programa principal
- `ssiv.sthlp`: Archivo de ayuda completo
- `example_ssiv.do`: Ejemplos básicos con datos simulados
- `SSIV_README.md`: Documentación extensa (14KB)
  - Background teórico
  - Múltiples ejemplos
  - Referencias académicas
  - Mejores prácticas

#### Referencias Implementadas
- Bartik, T. J. (1991)
- Goldsmith-Pinkham, Sorkin & Swift (2020, AER)
- Borusyak, Hull & Jaravel (2022, ReStud)
- Adão, Kolesár & Morales (2019, QJE)

---

## Próximas Versiones Planeadas

### [1.1.0] - Futuro
- [ ] Soporte para múltiples variables endógenas con múltiples instrumentos
- [ ] Implementación de correcciones de SE de Adão et al. (2019)
- [ ] Implementación de correcciones de SE de Borusyak et al. (2022)
- [ ] Tests de sobre-identificación integrados
- [ ] Exportación de resultados a LaTeX/Excel

### [1.2.0] - Futuro
- [ ] Análisis de sensibilidad automático
- [ ] Gráficos de diagnóstico
- [ ] Bootstrapping de errores estándar
- [ ] Análisis de influencia de sectores individuales

### [2.0.0] - Futuro
- [ ] Refactorización completa con Mata para mejor performance
- [ ] Soporte para datos panel
- [ ] Estimación con efectos fijos
- [ ] Suite completa de post-estimation commands

---

## Formato del Changelog

Este changelog sigue el formato de [Keep a Changelog](https://keepachangelog.com/es/1.0.0/).

### Tipos de Cambios
- **✨ Nuevas Características**: para funcionalidad nueva
- **🐛 Correcciones de Bugs**: para correcciones de bugs
- **📝 Documentación**: para cambios en documentación
- **⚡ Mejoras de Performance**: para mejoras de velocidad
- **♻️ Refactoring**: para cambios de código sin cambiar funcionalidad
- **🧪 Testing**: para añadir o modificar tests
- **⚠️ Deprecations**: para funcionalidad que será removida
- **🗑️ Removed**: para funcionalidad removida

### Severidad de Bugs
- **Crítico**: Causa fallos completos o resultados incorrectos
- **Importante**: Afecta funcionalidad significativa
- **Menor**: Afecta usabilidad pero no resultados
- **Cosmético**: Afecta solo apariencia/mensajes

---

## Versionado

Este proyecto sigue [Semantic Versioning](https://semver.org/):
- **MAJOR**: Cambios incompatibles en la API
- **MINOR**: Nueva funcionalidad compatible hacia atrás
- **PATCH**: Correcciones de bugs compatibles hacia atrás

Formato: `MAJOR.MINOR.PATCH` (e.g., `1.0.1`)
