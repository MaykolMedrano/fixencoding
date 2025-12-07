{smcl}
{* *! version 3.0  07dec2025}{...}
{vieweralsosee "[D] unicode translate" "help unicode translate"}{...}
{vieweralsosee "[D] unicode analyze" "help unicode analyze"}{...}
{viewerjumpto "Syntax" "fixencoding##syntax"}{...}
{viewerjumpto "Description" "fixencoding##description"}{...}
{viewerjumpto "Options" "fixencoding##options"}{...}
{viewerjumpto "Examples" "fixencoding##examples"}{...}
{viewerjumpto "Stored results" "fixencoding##results"}{...}
{viewerjumpto "Author" "fixencoding##author"}{...}
{title:Title}

{phang}
{bf:fixencoding} {hline 2} Batch character encoding conversion for Stata data files


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:fixencoding}
{it:filelist}
{cmd:,}
{opth from(encoding)}
[{it:options}]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opth from(encoding)}}source character encoding{p_end}

{syntab:Main}
{synopt:{opt replace}}overwrite original files with converted versions{p_end}
{synopt:{opth to(encoding)}}target character encoding; default is session encoding{p_end}
{synopt:{opth trans:latelog(filename)}}save translation log to file{p_end}

{syntab:Safety}
{synopt:{opt backup}}create backup of each file before conversion{p_end}
{synopt:{opth backups:uffix(string)}}suffix for backup files; default is {cmd:"_backup"}{p_end}
{synopt:{opt noexecute}}dry-run mode; show what would be done without making changes{p_end}
{synopt:{opt stoponfail}}stop processing on first error{p_end}

{syntab:Output}
{synopt:{opt q:uiet}}suppress progress messages{p_end}
{synopt:{opt v:erbose}}show detailed information{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:fixencoding} is a robust wrapper around Stata's {helpb unicode translate}
command that simplifies batch processing of multiple data files. It provides
enhanced error handling, progress reporting, backup functionality, and a
dry-run mode.

{pstd}
This command is designed to fix character encoding issues (accents, special
characters, etc.) that occur when opening datasets created in different
operating systems or older versions of Stata.

{pstd}
{it:filelist} specifies one or more files to process. You can specify:

{phang2}o A single file: {cmd:"mydata.dta"}{p_end}
{phang2}o Multiple files: {cmd:"file1.dta" "file2.dta" "file3.dta"}{p_end}
{phang2}o Wildcard patterns: {cmd:*.dta} or {cmd:survey_*.dta}{p_end}
{phang2}o Mixed: {cmd:"special file.dta" data*.dta}{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opth from(encoding)} specifies the source encoding of the files.
Common encodings include:

{phang3}{cmd:latin1} - ISO 8859-1, Western European{p_end}
{phang3}{cmd:windows-1252} - Windows Western European (includes euro sign){p_end}
{phang3}{cmd:iso-8859-15} - Latin-9, Western European with euro{p_end}
{phang3}{cmd:cp850} - DOS Latin-1{p_end}
{phang3}{cmd:macroman} - Mac OS Roman{p_end}

{pstd}
Use {helpb unicode analyze} to detect the encoding of your files.

{dlgtab:Main}

{phang}
{opt replace} specifies that the original files should be overwritten with
the converted versions. Without this option, the conversion results are
not saved.

{phang}
{opth to(encoding)} specifies the target encoding. By default, files are
converted to the session's encoding (typically UTF-8 in modern Stata).

{phang}
{opth translatelog(filename)} saves a detailed translation log to the
specified file. This log contains information about character mappings
and any issues encountered during conversion.

{dlgtab:Safety}

{phang}
{opt backup} creates a backup copy of each file before conversion.
Backups are saved with the suffix {cmd:_backup} (or the suffix specified
with {opt backupsuffix()}) before the {cmd:.dta} extension.

{phang}
{opth backupsuffix(string)} specifies the suffix for backup files.
Default is {cmd:"_backup"}. For example, with {cmd:backupsuffix(_orig)},
{cmd:mydata.dta} would be backed up as {cmd:mydata_orig.dta}.

{phang}
{opt noexecute} runs in dry-run mode. The command shows which files would
be processed and what operations would be performed, but does not make
any changes. Useful for verifying your file selection before conversion.

{phang}
{opt stoponfail} stops processing immediately when an error occurs.
By default, {cmd:fixencoding} continues processing remaining files
after an error and reports failures in the summary.

{dlgtab:Output}

{phang}
{opt quiet} suppresses all progress messages. Only errors are displayed.

{phang}
{opt verbose} displays additional information including backup creation
confirmations, the exact commands being executed, and a detailed list
of failed files (if any).


{marker examples}{...}
{title:Examples}

{pstd}
{ul:Basic usage}

{phang2}{cmd:. fixencoding "survey2020.dta", from(latin1) replace}{p_end}
{pmore}Converts a single file from Latin-1 to UTF-8.

{phang2}{cmd:. fixencoding *.dta, from(windows-1252) replace}{p_end}
{pmore}Converts all .dta files in the current directory.

{pstd}
{ul:Using backup protection}

{phang2}{cmd:. fixencoding ENH-*.dta, from(latin1) replace backup}{p_end}
{pmore}Converts files matching the pattern, creating backups first.

{phang2}{cmd:. fixencoding data.dta, from(latin1) replace backup backupsuffix(_v1)}{p_end}
{pmore}Creates backup as {cmd:data_v1.dta} before conversion.

{pstd}
{ul:Dry-run mode}

{phang2}{cmd:. fixencoding project_*.dta, from(latin1) noexecute}{p_end}
{pmore}Shows which files would be processed without making changes.

{pstd}
{ul:Batch processing with logging}

{phang2}{cmd:. fixencoding *.dta, from(latin1) replace translatelog(conversion_log.txt)}{p_end}
{pmore}Converts all files and saves a detailed log.

{pstd}
{ul:Multiple file patterns}

{phang2}{cmd:. fixencoding "encuesta nacional.dta" survey_*.dta, from(latin1) replace backup}{p_end}
{pmore}Processes a specific file and all files matching the pattern.

{pstd}
{ul:Quiet mode for scripts}

{phang2}{cmd:. fixencoding *.dta, from(latin1) replace quiet}{p_end}
{phang2}{cmd:. return list}{p_end}
{pmore}Runs silently; check results programmatically via stored results.


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:fixencoding} stores the following in {cmd:r()}:

{synoptset 24 tabbed}{...}
{p2col 5 24 28 2: Scalars}{p_end}
{synopt:{cmd:r(files_total)}}total number of files found{p_end}
{synopt:{cmd:r(files_success)}}number of files successfully converted{p_end}
{synopt:{cmd:r(files_failed)}}number of files that failed{p_end}
{synopt:{cmd:r(files_skipped)}}number of files skipped (non-.dta or no matches){p_end}

{p2col 5 24 28 2: Macros}{p_end}
{synopt:{cmd:r(encoding_from)}}source encoding specified{p_end}
{synopt:{cmd:r(encoding_to)}}target encoding (if specified){p_end}
{synopt:{cmd:r(files_processed)}}list of successfully processed files{p_end}
{synopt:{cmd:r(files_failed_list)}}list of files that failed{p_end}
{p2colreset}{...}


{marker author}{...}
{title:Author}

{pstd}
Multiple contributors{break}
GitHub repository: {browse "https://github.com/MaykolMedrano/fixencoding"}


{marker alsosee}{...}
{title:Also see}

{psee}
Manual: {manlink D unicode translate}, {manlink D unicode analyze}

{psee}
{helpb unicode translate}, {helpb unicode analyze}, {helpb unicode encoding}
{p_end}
