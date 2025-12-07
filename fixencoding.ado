*! fixencoding v3.0
*! Character encoding conversion utility
*! Robust wrapper for unicode translate with batch processing support
*! Date: 2025-12-07

capture program drop fixencoding
program define fixencoding, rclass
    version 14.0

    // ==========================================================================
    // SYNTAX DEFINITION
    // ==========================================================================
    syntax anything(name=filelist), ///
        from(string)                /// Source encoding (required)
        [                           ///
        replace                     /// Overwrite original files
        to(string)                  /// Target encoding (default: session encoding)
        TRANSlatelog(string)        /// Log file for translation details
        backup                      /// Create backup before modifying
        BACKUPSuffix(string)        /// Backup file suffix (default: "_backup")
        noexecute                   /// Dry-run mode: show what would be done
        Quiet                       /// Suppress progress messages
        Verbose                     /// Show detailed information
        stoponfail                  /// Stop processing on first error
        ]

    // ==========================================================================
    // INITIALIZATION
    // ==========================================================================
    local total_files = 0
    local success_count = 0
    local fail_count = 0
    local skip_count = 0
    local failed_files ""
    local processed_files ""

    // Set default backup suffix
    if "`backupsuffix'" == "" {
        local backupsuffix "_backup"
    }

    // Handle quiet/verbose conflict
    if "`quiet'" != "" & "`verbose'" != "" {
        display as error "Options {bf:quiet} and {bf:verbose} cannot be used together"
        exit 198
    }

    // ==========================================================================
    // HEADER DISPLAY
    // ==========================================================================
    if "`quiet'" == "" {
        display as text ""
        display as text "{hline 70}"
        display as text "{bf:fixencoding v3.0} - Character Encoding Conversion"
        display as text "{hline 70}"
        display as text "  Source encoding: {result:`from'}"
        if "`to'" != "" {
            display as text "  Target encoding: {result:`to'}"
        }
        else {
            display as text "  Target encoding: {result:(session default)}"
        }
        if "`noexecute'" != "" {
            display as text ""
            display as result "  {bf:[DRY-RUN MODE]} No files will be modified"
        }
        display as text "{hline 70}"
        display as text ""
    }

    // ==========================================================================
    // EXPAND FILE LIST (handle wildcards)
    // ==========================================================================
    local expanded_files ""

    foreach pattern of local filelist {
        // Remove quotes if present
        local pattern = subinstr("`pattern'", `"""', "", .)

        // Check if pattern contains wildcards
        local has_wildcard = 0
        if strpos("`pattern'", "*") > 0 | strpos("`pattern'", "?") > 0 {
            local has_wildcard = 1
        }

        if `has_wildcard' {
            // Use dir to expand wildcards
            quietly {
                local files_found : dir "." files "`pattern'"
            }
            if `"`files_found'"' == "" {
                if "`quiet'" == "" {
                    display as error "  Warning: No files match pattern '{bf:`pattern'}'"
                }
                local ++skip_count
            }
            else {
                foreach f of local files_found {
                    local expanded_files `"`expanded_files' "`f'""'
                }
            }
        }
        else {
            // Single file - add to list
            local expanded_files `"`expanded_files' "`pattern'""'
        }
    }

    // Check if we have any files to process
    if `"`expanded_files'"' == "" {
        display as error "No files to process"
        return scalar files_total = 0
        return scalar files_success = 0
        return scalar files_failed = 0
        return scalar files_skipped = `skip_count'
        exit 601
    }

    // ==========================================================================
    // PROCESS EACH FILE
    // ==========================================================================
    foreach f of local expanded_files {
        local ++total_files

        // Remove quotes for display
        local f_display = subinstr("`f'", `"""', "", .)

        // ---------------------------------------------------------------------
        // Check if file exists
        // ---------------------------------------------------------------------
        capture confirm file "`f'"
        if _rc != 0 {
            local ++fail_count
            local failed_files `"`failed_files' "`f'""'
            if "`quiet'" == "" {
                display as error "  [{bf:`total_files'}] File not found: {bf:`f_display'}"
            }
            if "`stoponfail'" != "" {
                display as error "Stopping due to {bf:stoponfail} option"
                continue, break
            }
            continue
        }

        // ---------------------------------------------------------------------
        // Check if file is a .dta file
        // ---------------------------------------------------------------------
        if !regexm(lower("`f'"), "\.dta$") {
            local ++skip_count
            if "`quiet'" == "" & "`verbose'" != "" {
                display as text "  [{bf:`total_files'}] Skipping non-.dta file: {bf:`f_display'}"
            }
            continue
        }

        // ---------------------------------------------------------------------
        // Display progress
        // ---------------------------------------------------------------------
        if "`quiet'" == "" {
            if "`noexecute'" != "" {
                display as text "  [{bf:`total_files'}] Would process: {result:`f_display'}"
            }
            else {
                display as text "  [{bf:`total_files'}] Processing: {result:`f_display'}" _continue
            }
        }

        // ---------------------------------------------------------------------
        // Create backup if requested
        // ---------------------------------------------------------------------
        if "`backup'" != "" & "`noexecute'" == "" {
            local backup_name = subinstr("`f'", ".dta", "`backupsuffix'.dta", 1)
            capture copy "`f'" "`backup_name'", replace
            if _rc != 0 {
                local ++fail_count
                local failed_files `"`failed_files' "`f'""'
                if "`quiet'" == "" {
                    display as error " -> FAILED (backup error)"
                }
                if "`stoponfail'" != "" {
                    display as error "Stopping due to {bf:stoponfail} option"
                    continue, break
                }
                continue
            }
            if "`verbose'" != "" & "`quiet'" == "" {
                display as text ""
                display as text "         Backup created: {result:`backup_name'}"
                display as text "         " _continue
            }
        }

        // ---------------------------------------------------------------------
        // Execute unicode translate (unless dry-run)
        // ---------------------------------------------------------------------
        if "`noexecute'" == "" {
            // Build command with only specified options
            local cmd `"unicode translate "`f'", from("`from'")"'

            if "`to'" != "" {
                local cmd `"`cmd' to("`to'")"'
            }

            if "`translatelog'" != "" {
                local cmd `"`cmd' translatelog("`translatelog'")"'
            }

            if "`replace'" != "" {
                local cmd `"`cmd' replace"'
            }

            // Execute with error capture
            capture `cmd'
            local rc = _rc

            if `rc' != 0 {
                local ++fail_count
                local failed_files `"`failed_files' "`f'""'
                if "`quiet'" == "" {
                    display as error " -> FAILED (error code: `rc')"
                }
                if "`verbose'" != "" {
                    display as error "         Command: `cmd'"
                }
                if "`stoponfail'" != "" {
                    display as error "Stopping due to {bf:stoponfail} option"
                    continue, break
                }
            }
            else {
                local ++success_count
                local processed_files `"`processed_files' "`f'""'
                if "`quiet'" == "" {
                    display as result " -> OK"
                }
            }
        }
        else {
            // Dry-run mode: count as would-be-success
            local ++success_count
        }
    }

    // ==========================================================================
    // SUMMARY
    // ==========================================================================
    if "`quiet'" == "" {
        display as text ""
        display as text "{hline 70}"
        display as text "{bf:Summary}"
        display as text "{hline 70}"
        display as text "  Total files found:    {result:`total_files'}"
        if "`noexecute'" != "" {
            display as text "  Would be processed:   {result:`success_count'}"
        }
        else {
            display as text "  Successfully converted: {result:`success_count'}"
        }
        if `fail_count' > 0 {
            display as error "  Failed:               `fail_count'"
        }
        if `skip_count' > 0 {
            display as text "  Skipped:              {result:`skip_count'}"
        }
        display as text "{hline 70}"
        display as text ""

        // Show failed files if any
        if `fail_count' > 0 & "`verbose'" != "" {
            display as error "Failed files:"
            foreach ff of local failed_files {
                display as error "  - `ff'"
            }
            display as text ""
        }
    }

    // ==========================================================================
    // RETURN VALUES
    // ==========================================================================
    return scalar files_total = `total_files'
    return scalar files_success = `success_count'
    return scalar files_failed = `fail_count'
    return scalar files_skipped = `skip_count'
    return local encoding_from "`from'"
    return local encoding_to "`to'"
    return local files_processed `"`processed_files'"'
    return local files_failed_list `"`failed_files'"'

    // Exit with error if any files failed (unless noexecute)
    if `fail_count' > 0 & "`noexecute'" == "" {
        exit 198
    }

end
