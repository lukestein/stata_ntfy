*! version 1.3.4  18dec2025
program define ntfy
    version 14
    syntax anything(name=args id="Message or Topic+Message") [, Title(string) Priority(string) Tags(string) DELAY(string) TOPIC(string)]

    /* -------------------------------------------------------------------------
       1. Load Preferences & Parse Input
       ------------------------------------------------------------------------- */
    * Ensure defaults are loaded
    if "$NTFY_TOPIC" == "" {
        capture program drop ntfy_prefs
        capture ntfy_prefs
    }

    gettoken t1 t2 : args
    
    * LOGIC TREE
    
    * A. Explicit Option: ntfy "msg", topic(xyz)
    if "`topic'" != "" {
        local final_topic "`topic'"
        local message `"`args'"'
    }
    * B. Two Arguments: ntfy xyz "msg" (Override Default)
    else if `"`t2'"' != "" {
        local final_topic "`t1'"
        local message `"`t2'"'
    }
    * C. One Argument + Default Exists: ntfy "msg" -> Sends to Default
    else if `"`t2'"' == "" & "$NTFY_TOPIC" != "" {
        local final_topic "$NTFY_TOPIC"
        local message `"`t1'"'
    }
    * D. One Argument + No Default: ntfy xyz -> Sends "Job completed" to xyz
    else {
        local final_topic "`t1'"
        local message "Stata job completed."
    }

    /* -------------------------------------------------------------------------
       2. Sanitize Message
       ------------------------------------------------------------------------- */
    local message = trim(`"`message'"')
    
    * Strip outer quotes (if user provided "Message")
    if substr(`"`message'"', 1, 1) == char(34) & substr(`"`message'"', -1, 1) == char(34) {
        local msg_len = length(`"`message'"') - 2
        local message = substr(`"`message'"', 2, `msg_len')
    }
    
    * Sanitize internal quotes
    local message = subinstr(`"`message'"', char(34), "'", .)

    /* -------------------------------------------------------------------------
       3. Construct Headers
       ------------------------------------------------------------------------- */
    local headers ""
    if `"`title'"' != "" {
        local clean_title = subinstr(`"`title'"', char(34), "'", .)
        local headers `headers' -H "Title: `clean_title'"
    }
    if `"`priority'"' != "" local headers `headers' -H "Priority: `priority'"
    if `"`tags'"' != ""     local headers `headers' -H "Tags: `tags'"
    if `"`delay'"' != ""    local headers `headers' -H "Delay: `delay'"

    /* -------------------------------------------------------------------------
       4. Execution based on OS
       ------------------------------------------------------------------------- */
    if c(os) == "Windows" {
        local ps_headers ""
        if `"`title'"' != ""    local ps_headers `ps_headers' "Title"='`title''; 
        if `"`priority'"' != "" local ps_headers `ps_headers' "Priority"='`priority''; 
        if `"`tags'"' != ""     local ps_headers `ps_headers' "Tags"='`tags''; 
        if `"`delay'"' != ""    local ps_headers `ps_headers' "Delay"='`delay''; 
        
        if `"`ps_headers'"' != "" local ps_header_cmd -Headers @{`ps_headers'}
        
        local ps_message = subinstr(`"`message'"', "'", "''", .)
        shell powershell -NoProfile -Command "Invoke-RestMethod -Uri 'https://ntfy.sh/`final_topic'' -Method Post -Body '`ps_message'' `ps_header_cmd'"
    }
    else {
        * FIX: Use 'sh -c' with SINGLE quotes.
        * This hides PID output, supports standard redirection, and avoids tcsh quoting errors.
        
        * 1. Build the raw curl command (standard bash/zsh syntax)
        local curl_cmd curl -s `headers' -d "`message'" ntfy.sh/`final_topic' >/dev/null 2>&1 &
        
        * 2. Escape any single quotes inside the command ( ' becomes '\'' )
        * This ensures the command can be safely wrapped in single quotes below.
        local curl_cmd = subinstr(`"`curl_cmd'"', "'", "'\''", .)
        
        * 3. Execute using sh -c '...'
        shell sh -c '`curl_cmd''
    }    
    
    di as txt "Notification sent to ntfy.sh/`final_topic'"
end