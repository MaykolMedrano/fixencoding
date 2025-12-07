# `fixencoding`: Utilidad para la Conversión de Codificación en Stata

<p align="left">
  <img src="https://img.shields.io/badge/Stata-v14%2B-blue" alt="Stata Version">
  <img src="https://img.shields.io/badge/Release-v3.0-blue" alt="Current Release">
  <img src="https://img.shields.io/badge/Updated-December_2025-green" alt="Last Updated">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>

[Instalación](#instalación) | [Sintaxis](#sintaxis-del-comando) | [Opciones](#opciones) | [Ejemplos](#ejemplos-de-uso) | [Historial](#historial-de-versiones)

---

## Resumen

`fixencoding` es una utilidad robusta para Stata que simplifica y automatiza la corrección de la codificación de caracteres en archivos de datos (`.dta`). Actúa como un wrapper mejorado del comando nativo `unicode translate`, ofreciendo:

- Procesamiento por lotes con soporte de comodines
- Respaldos automáticos antes de modificar
- Modo dry-run para previsualizar cambios
- Manejo robusto de errores
- Resultados programáticos vía `return list`

## Características Principales

| Característica | Descripción |
|---------------|-------------|
| **Procesamiento por Lotes** | Convierte múltiples archivos `.dta` con una sola línea de código |
| **Respaldos Automáticos** | Opción `backup` para crear copias de seguridad antes de modificar |
| **Modo Dry-Run** | Opción `noexecute` para ver qué archivos se procesarían sin hacer cambios |
| **Manejo de Errores** | Continúa procesando otros archivos si uno falla, con resumen detallado |
| **Resultados Almacenados** | Acceso programático a estadísticas vía `r()` |
| **Salida Configurable** | Opciones `quiet` y `verbose` para controlar mensajes |

## Requisitos Previos

- **Stata versión 14 o superior**
- **Conexión a internet** para instalación directa

## Instalación

### Desde el Repositorio Online

```stata
// Desinstalar versión anterior (opcional)
capture ado uninstall fixencoding

// Instalar desde GitHub
net install fixencoding, from("https://raw.githubusercontent.com/MaykolMedrano/fixencoding/main/")
```

### Instalación Manual

Descargue `fixencoding.ado` y `fixencoding.sthlp` y cópielos a su directorio PERSONAL de Stata:

```stata
// Encontrar el directorio PERSONAL
sysdir
```

## Sintaxis del Comando

```stata
fixencoding filelist , from(encoding) [options]
```

## Opciones

### Requeridas

| Opción | Descripción |
|--------|-------------|
| `from(encoding)` | Codificación de origen de los archivos (ej: `latin1`, `windows-1252`) |

### Principales

| Opción | Descripción |
|--------|-------------|
| `replace` | Sobrescribir los archivos originales con las versiones convertidas |
| `to(encoding)` | Codificación de destino (por defecto: codificación de la sesión) |
| `translatelog(filename)` | Guardar log de traducción en archivo |

### Seguridad

| Opción | Descripción |
|--------|-------------|
| `backup` | Crear respaldo de cada archivo antes de la conversión |
| `backupsuffix(string)` | Sufijo para archivos de respaldo (por defecto: `"_backup"`) |
| `noexecute` | Modo dry-run: muestra qué se haría sin hacer cambios |
| `stoponfail` | Detener procesamiento en el primer error |

### Salida

| Opción | Descripción |
|--------|-------------|
| `quiet` | Suprimir mensajes de progreso |
| `verbose` | Mostrar información detallada |

## Ejemplos de Uso

### Uso Básico

```stata
// Convertir un único archivo
fixencoding "encuesta2020.dta", from(latin1) replace

// Convertir todos los archivos .dta del directorio
fixencoding *.dta, from(windows-1252) replace
```

### Con Respaldo de Seguridad

```stata
// Crear respaldo antes de convertir
fixencoding datos.dta, from(latin1) replace backup

// Respaldo con sufijo personalizado
fixencoding datos.dta, from(latin1) replace backup backupsuffix(_original)
// Crea: datos_original.dta
```

### Modo Dry-Run (Previsualización)

```stata
// Ver qué archivos se procesarían sin hacer cambios
fixencoding proyecto_*.dta, from(latin1) noexecute
```

### Procesamiento Silencioso para Scripts

```stata
// Ejecutar sin mensajes, verificar resultados programáticamente
fixencoding *.dta, from(latin1) replace quiet

// Ver resultados
display "Archivos procesados: " r(files_success)
display "Archivos fallidos: " r(files_failed)
```

### Múltiples Patrones de Archivos

```stata
// Combinar archivo específico con patrón
fixencoding "encuesta nacional.dta" survey_*.dta, from(latin1) replace backup
```

### Con Registro de Traducción

```stata
// Guardar log detallado de la conversión
fixencoding *.dta, from(latin1) replace translatelog(conversion_log.txt)
```

## Resultados Almacenados

Después de ejecutar `fixencoding`, los siguientes valores están disponibles en `r()`:

### Escalares

| Resultado | Descripción |
|-----------|-------------|
| `r(files_total)` | Total de archivos encontrados |
| `r(files_success)` | Archivos convertidos exitosamente |
| `r(files_failed)` | Archivos que fallaron |
| `r(files_skipped)` | Archivos omitidos (no-.dta o sin coincidencias) |

### Macros

| Resultado | Descripción |
|-----------|-------------|
| `r(encoding_from)` | Codificación de origen especificada |
| `r(encoding_to)` | Codificación de destino (si se especificó) |
| `r(files_processed)` | Lista de archivos procesados exitosamente |
| `r(files_failed_list)` | Lista de archivos que fallaron |

### Ejemplo de Uso Programático

```stata
fixencoding *.dta, from(latin1) replace quiet

if r(files_failed) > 0 {
    display as error "Hubo " r(files_failed) " archivos con errores"
    display as error "Archivos fallidos: " r(files_failed_list)
}
else {
    display as result "Todos los " r(files_success) " archivos convertidos exitosamente"
}
```

## Codificaciones Comunes

| Codificación | Descripción | Uso Común |
|-------------|-------------|-----------|
| `latin1` | ISO 8859-1 | Europa Occidental, América Latina |
| `windows-1252` | CP1252 | Windows en español/europeo |
| `iso-8859-15` | Latin-9 | Similar a latin1 + símbolo euro |
| `cp850` | DOS Latin-1 | Archivos DOS antiguos |
| `macroman` | Mac Roman | Mac OS clásico |

### Detectar Codificación

Use `unicode analyze` para detectar la codificación de sus archivos:

```stata
unicode analyze *.dta
```

## Historial de Versiones

### v3.0 (2025-12-07)
- Manejo robusto de errores con continuación automática
- Opción `backup` para crear respaldos automáticos
- Opción `noexecute` para modo dry-run
- Opciones `quiet` y `verbose` para controlar salida
- Opción `stoponfail` para detener en primer error
- Resultados almacenados en `r()` para uso programático
- Validación de existencia de archivos
- Soporte mejorado para comodines
- Archivo de ayuda integrado (`help fixencoding`)
- Resumen detallado al finalizar

### v2.0 (2025-07-28)
- Añadido soporte para `to()` y `translatelog()`
- Documentación para instalación vía `net install`

### v1.0 (2025-07-28)
- Versión inicial con `from()` y `replace`

## Licencia

MIT License - Copyright (c) 2025

Se concede permiso para usar, copiar, modificar, fusionar, publicar, distribuir, sublicenciar y/o vender copias del Software.

## Véase También

- `help unicode translate` - Comando nativo de Stata
- `help unicode analyze` - Detectar codificación de archivos
- `help unicode encoding` - Lista de codificaciones soportadas
