*! version 1.1.0  18dec2025
program define ntfy
    version 14
    syntax anything(name=args id="Topic and Message") [, Title(string) Priority(string) Tags(string) DELAY(string)]

    /* -------------------------------------------------------------------------
       1. Parse Input
       ------------------------------------------------------------------------- */
    gettoken topic message : args
    
    * TRIM WHITESPACE (in case user typed: ntfy topic   Message)
    local message = trim(`"`message'"')

    * STRIP OUTER QUOTES
    * If the message starts and ends with double quotes, remove them.
    if substr(`"`message'"', 1, 1) == char(34) & substr(`"`message'"', -1, 1) == char(34) {
        local msg_len = length(`"`message'"') - 2
        local message = substr(`"`message'"', 2, `msg_len')
    }

    * SANITIZE INTERNAL QUOTES
    * Replace remaining double quotes with single quotes to prevent shell command breakage.
    * Example: 'Error in "regress"' becomes 'Error in 'regress''
    local message = subinstr(`"`message'"', char(34), "'", .)
    
    * Default message if empty
    if `"`message'"' == "" {
        local message "Stata job completed."
    }

    /* -------------------------------------------------------------------------
       2. Construct Headers
       ------------------------------------------------------------------------- */
    local headers ""
    
    if `"`title'"' != "" {
        local clean_title = subinstr(`"`title'"', char(34), "'", .)
        local headers `headers' -H "Title: `clean_title'"
    }
    
    if `"`priority'"' != "" {
        local headers `headers' -H "Priority: `priority'"
    }
    
    if `"`tags'"' != "" {
        local headers `headers' -H "Tags: `tags'"
    }

    if `"`delay'"' != "" {
        local headers `headers' -H "Delay: `delay'"
    }

    /* -------------------------------------------------------------------------
       3. Execution based on OS
       ------------------------------------------------------------------------- */
    if c(os) == "Windows" {
        * WINDOWS (PowerShell)
        
        * Construct the PowerShell headers hash
        local ps_headers ""
        if `"`title'"' != "" local ps_headers `ps_headers' "Title"='`title''; 
        if `"`priority'"' != "" local ps_headers `ps_headers' "Priority"='`priority''; 
        if `"`tags'"' != "" local ps_headers `ps_headers' "Tags"='`tags''; 
        if `"`delay'"' != "" local ps_headers `ps_headers' "Delay"='`delay''; 
        
        if `"`ps_headers'"' != "" {
            local ps_header_cmd -Headers @{`ps_headers'}
        }
        
        * Escape single quotes for PowerShell (replace ' with '')
        local ps_message = subinstr(`"`message'"', "'", "''", .)
        
        shell powershell -NoProfile -Command "Invoke-RestMethod -Uri 'https://ntfy.sh/`topic'' -Method Post -Body '`ps_message'' `ps_header_cmd'"
    }
    else {
        * MAC / UNIX (cURL)
        * Runs in background (&) to avoid locking Stata
        shell curl -s `headers' -d "`message'" ntfy.sh/`topic' >/dev/null 2>&1 &
    }
    
    di as txt "Notification sent to ntfy.sh/`topic'"
end
