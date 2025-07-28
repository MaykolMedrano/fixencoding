# `fixencoding`: Utilidad para la Conversión de Codificación en Stata

<p align="left">
  <img src="https://img.shields.io/badge/Stata-v14%2B-blue" alt="Stata Version">
  <img src="https://img.shields.io/badge/Release-v2.0-blue" alt="Current Release">
  <img src="https://img.shields.io/badge/Updated-July_2025-green" alt="Last Updated">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>

[Instalación](#instalación) | [Sintaxis](#sintaxis-del-comando) | [Ejemplos](#ejemplos-de-uso) | [Historial de Versiones](#historial-de-versiones) | [Licencia](#licencia)

---

## Resumen

El programa `fixencoding` es una utilidad para Stata que simplifica y automatiza la corrección de la codificación de caracteres en archivos de datos (`.dta`). Actúa como un contenedor (wrapper) del comando nativo `unicode translate`, permitiendo el procesamiento por lotes de múltiples archivos a través de una sintaxis clara y concisa.

Esta herramienta está diseñada para resolver problemas comunes de visualización de caracteres especiales (acentos, ñ, etc.) que surgen al trabajar con datasets creados en diferentes sistemas operativos o versiones antiguas de Stata.

## Tabla de Contenidos
1. [Descripción General](#descripción-general)
2. [Características Principales](#características-principales)
3. [Requisitos Previos](#requisitos-previos)
4. [Instalación](#instalación)
5. [Sintaxis del Comando](#sintaxis-del-comando)
6. [Parámetros y Opciones](#parámetros-y-opciones)
7. [Ejemplos de Uso](#ejemplos-de-uso)
8. [Código Fuente](#código-fuente-del-programa)
9. [Historial de Versiones](#historial-de-versiones)
10. [Licencia](#licencia)

## Descripción General

En el análisis de datos es frecuente encontrar archivos `.dta` con problemas de codificación. Esto ocurre cuando un archivo guardado con una codificación heredada (ej. `latin1`, `windows-1252`) se abre en una sesión de Stata moderna que utiliza `UTF-8`. El resultado es la incorrecta representación de caracteres no ingleses.

`fixencoding` abstrae la lógica de `unicode translate` en un único comando robusto que puede operar sobre un conjunto de archivos especificado mediante comodines, mejorando significativamente la eficiencia del flujo de trabajo de preparación de datos.

## Características Principales

* **Procesamiento por Lotes:** Permite convertir múltiples archivos `.dta` con una sola línea de código.
* **Instalación Sencilla:** Se instala directamente desde un repositorio online usando `net install`.
* **Sintaxis Simplificada:** Ofrece una interfaz de usuario clara y directa para una tarea compleja.
* **Integración Completa:** Soporta las opciones más importantes de `unicode translate`.

## Requisitos Previos

* **Stata versión 14 o superior.**
* **Conexión a internet** para la instalación directa.

## Instalación

El paquete se puede instalar directamente desde su repositorio online.

Ejecute los siguientes comandos en la consola de Stata:

```stata
// 1. Opcional: desinstalar cualquier versión anterior para asegurar una instalación limpia
capture ado uninstall fixencoding

// 2. Instalar desde el repositorio online
net install fixencoding, from("[https://raw.githubusercontent.com/nombre-de-usuario/fixencoding/main/](https://raw.githubusercontent.com/nombre-de-usuario/fixencoding/main/)")
```

> **Nota Importante:** La URL anterior es un ejemplo. Si usted aloja este código, debe reemplazar `"nombre-de-usuario/fixencoding"` con su nombre de usuario y el nombre de su repositorio en GitHub. Para que `net install` funcione, la carpeta en el repositorio debe contener el archivo `fixencoding.ado` y un archivo `stata.toc`.

### Instalación Manual

Si prefiere una instalación local, copie el [código fuente](#código-fuente-del-programa) y guárdelo en un archivo llamado `fixencoding.ado` dentro de su directorio `PERSONAL` de Stata. (Use `findit personal` para encontrar la ruta).

## Sintaxis del Comando

```stata
fixencoding filelist , from(encoding) [replace to(encoding) translatelog(newfile)]
```

## Parámetros y Opciones

* `filelist` (Requerido): Especifica el archivo o los archivos a procesar. Acepta el nombre de un único archivo (`"datos.dta"`) o un patrón con comodines (`"*.dta"`).
* `from(encoding)` (Requerido): Define la codificación de origen de los archivos. Ejemplos: `latin1`, `windows-1252`.
* `replace` (Opcional): Autoriza al comando a sobrescribir los archivos originales. **Sin esta opción, los cambios no se guardarán.**
* `to(encoding)` (Opcional): Define la codificación de destino. Por defecto, es la de la sesión actual (`UTF-8`).
* `translatelog(newfile)` (Opcional): Genera un informe de texto detallado de la traducción.

## Ejemplos de Uso

### Ejemplo 1: Convertir un único archivo
```stata
fixencoding "encuesta nacional 2010.dta", from(latin1) replace
```

### Ejemplo 2: Convertir todos los archivos de una carpeta
```stata
fixencoding *.dta, from(windows-1252) replace
```

### Ejemplo 3: Uso avanzado con registro de traducción
```stata
fixencoding ENH-*.dta, from(latin1) replace translatelog(reporte_conversion.txt)
```

## Código Fuente del Programa
```stata
* --- Código para crear el comando fixencoding (Versión 2.0) ---
capture program drop fixencoding
program define fixencoding
    
    // Define la sintaxis del comando y sus opciones
    syntax anything(name=filelist), from(string) [replace to(string) translatelog(string)]
    
    // Bucle para procesar cada archivo en la lista proporcionada
    foreach f of local filelist {
        display as text "Traduciendo archivo: `f'..."
        
        // Ejecuta unicode translate pasando las opciones
        unicode translate "`f'", from("`from'") to("`to'") translatelog("`translatelog'") `replace'
        
        display as result "  -> Traducción completada."
    }
end
* --- Fin del código ---
```

## Historial de Versiones

* **v2.0 (2025-07-28):**
    * Añadido soporte para las opciones `to()` y `translatelog()`.
    * Actualizada la documentación para incluir instalación vía `net install`.
* **v1.0 (2025-07-28):**
    * Versión inicial con funcionalidad básica de `from()` y `replace`.

## Licencia

Este proyecto se distribuye bajo la Licencia MIT.

Copyright (c) 2025

Se concede permiso, por la presente, libre de cargos, a cualquier persona que obtenga una copia de este software y de los archivos de documentación asociados (el "Software"), para tratar en el Software sin restricción, incluyendo sin limitación los derechos de usar, copiar, modificar, fusionar, publicar, distribuir, sublicenciar, y/o vender copias del Software, y para permitir a las personas a las que se les proporcione el Software a hacer lo mismo, sujeto a las siguientes condiciones:

El aviso de copyright anterior y este aviso de permiso se incluirán en todas las copias o porciones sustanciales del Software.

EL SOFTWARE SE PROPORCIONA "COMO ESTÁ", SIN GARANTÍA DE NINGÚN TIPO, EXPRESA O IMPLÍCITA, INCLUYENDO PERO NO LIMITADO A GARANTÍAS DE COMERCIABILIDAD, IDONEIDAD PARA UN PROPÓSITO PARTICULAR Y NO INFRACCIÓN. EN NINGÚN CASO LOS AUTORES O TITULARES DEL COPYRIGHT SERÁN RESPONSABLES DE NINGUNA RECLAMACIÓN, DAÑO U OTRA RESPONSABILIDAD, YA SEA EN UNA ACCIÓN DE CONTRATO, AGRAVIO O CUALQUIER OTRO MOTIVO, QUE SURJA DE, FUERA DE O EN CONEXIÓN CON EL SOFTWARE O EL USO U OTROS TRATOS EN EL SOFTWARE.
