# `fixencoding`: Utilidad para la Conversión de Codificación en Stata

**Versión:** 2.0  
**Fecha de última actualización:** 2025-07-28  
**Autor:** Generado mediante asistencia de IA  

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
8. [Historial de Versiones](#historial-de-versiones)
9. [Licencia](#licencia)

## Descripción General

En el análisis de datos es frecuente encontrar archivos `.dta` con problemas de codificación. Esto ocurre cuando un archivo guardado con una codificación heredada (ej. `latin1`, `windows-1252`) se abre en una sesión de Stata moderna que utiliza `UTF-8`. El resultado es la incorrecta representación de caracteres no ingleses.

El comando `unicode translate` de Stata resuelve este problema, pero su aplicación a múltiples archivos puede ser repetitiva. `fixencoding` abstrae esta lógica en un único comando robusto que puede operar sobre un conjunto de archivos especificado mediante comodines, mejorando significativamente la eficiencia del flujo de trabajo de preparación de datos.

## Características Principales

* **Procesamiento por Lotes:** Permite convertir múltiples archivos `.dta` con una sola línea de código.
* **Sintaxis Simplificada:** Ofrece una interfaz de usuario clara y directa para una tarea compleja.
* **Integración Completa:** Soporta las opciones más importantes del comando subyacente `unicode translate`, como `from`, `to`, `replace` y `translatelog`.
* **Registro Detallado:** Facilita la depuración de conversiones mediante la generación de archivos de registro (`log`).

## Requisitos Previos

* **Stata versión 14 o superior.** Se recomienda una versión reciente para asegurar la compatibilidad completa con la suite de comandos `unicode`.

## Instalación

Para utilizar `fixencoding`, el programa debe ser cargado en la memoria de Stata. Existen dos métodos para lograrlo:

### Método 1: Carga por Sesión

Copie el código completo del programa (ver sección [Código Fuente](#código-fuente-del-programa)) y péguelo en la ventana de Comandos de Stata o al inicio de su do-file. El comando `fixencoding` estará disponible durante esa sesión.

### Método 2: Instalación Permanente (Recomendado)

1.  Cree un nuevo archivo de texto plano.
2.  Copie el código fuente del programa en este archivo.
3.  Guárdelo con el nombre `fixencoding.ado` en su directorio `PERSONAL` de Stata. Para encontrar la ruta de este directorio, ejecute en Stata el comando: `findit personal`.

Una vez guardado en dicha ubicación, Stata cargará el comando automáticamente en cada inicio.

## Sintaxis del Comando

```stata
fixencoding filelist , from(encoding) [replace to(encoding) translatelog(newfile)]
```

## Parámetros y Opciones

* `filelist` (Requerido): Especifica el archivo o los archivos a procesar. Acepta el nombre de un único archivo (`"datos.dta"`) o un patrón con comodines para múltiples archivos (`"*.dta"`).
* `from(encoding)` (Requerido): Define la codificación de origen de los archivos. Es el parámetro más crítico para una correcta traducción. Ejemplos: `latin1`, `windows-1252`.
* `replace` (Opcional): Autoriza al comando a sobrescribir los archivos originales en el disco con su versión traducida. **Sin esta opción, los cambios no se guardarán.**
* `to(encoding)` (Opcional): Define la codificación de destino. Por defecto, los archivos se convierten a la codificación de la sesión actual de Stata (`UTF-8` en versiones modernas).
* `translatelog(newfile)` (Opcional): Genera un archivo de texto con un informe detallado de la traducción, ideal para la auditoría y depuración del proceso.

## Ejemplos de Uso

### Ejemplo 1: Convertir un único archivo
```stata
fixencoding "encuesta nacional 2010.dta", from(latin1) replace
```

### Ejemplo 2: Convertir todos los archivos `.dta` de una carpeta
```stata
fixencoding *.dta, from(windows-1252) replace
```

### Ejemplo 3: Uso avanzado con registro de traducción
```stata
fixencoding ENH-*.dta, from(latin1) replace translatelog(reporte_traduccion.txt)
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
    * Mejorada la retroalimentación en la consola.
* **v1.0 (2025-07-28):**
    * Versión inicial con funcionalidad básica de `from()` y `replace`.

## Licencia

Este proyecto se distribuye bajo la Licencia MIT.

Copyright (c) 2025

Se concede permiso, por la presente, libre de cargos, a cualquier persona que obtenga una copia de este software y de los archivos de documentación asociados (el "Software"), para tratar en el Software sin restricción, incluyendo sin limitación los derechos de usar, copiar, modificar, fusionar, publicar, distribuir, sublicenciar, y/o vender copias del Software, y para permitir a las personas a las que se les proporcione el Software a hacer lo mismo, sujeto a las siguientes condiciones:

El aviso de copyright anterior y este aviso de permiso se incluirán en todas las copias o porciones sustanciales del Software.

EL SOFTWARE SE PROPORCIONA "COMO ESTÁ", SIN GARANTÍA DE NINGÚN TIPO, EXPRESA O IMPLÍCITA, INCLUYENDO PERO NO LIMITADO A GARANTÍAS DE COMERCIABILIDAD, IDONEIDAD PARA UN PROPÓSITO PARTICULAR Y NO INFRACCIÓN. EN NINGÚN CASO LOS AUTORES O TITULARES DEL COPYRIGHT SERÁN RESPONSABLES DE NINGUNA RECLAMACIÓN, DAÑO U OTRA RESPONSABILIDAD, YA SEA EN UNA ACCIÓN DE CONTRATO, AGRAVIO O CUALQUIER OTRO MOTIVO, QUE SURJA DE, FUERA DE O EN CONEXIÓN CON EL SOFTWARE O EL USO U OTROS TRATOS EN EL SOFTWARE.
