*! fixencoding v2.0
*! Character encoding conversion utility
*! Wrapper for unicode translate with batch processing support
*! Date: 2025-07-28

capture program drop fixencoding
program define fixencoding
    version 14.0

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
