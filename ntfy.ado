*! version 1.4.0  23dec2025
program define ntfy
    version 14
    syntax anything(name=args id="Message or Topic+Message") [, Title(string) Priority(string) Tags(string) DELAY(string) TOPIC(string) GRAPH GRAPHName(string) Width(integer 1200)]

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
       3. Handle Graph Export (if requested)
       ------------------------------------------------------------------------- */
    local graphfile ""
    
    * If graphname is specified, it implies graph option
    if "`graphname'" != "" {
        local graph "graph"
    }
    
    if "`graph'" != "" {
        * Create temporary file for graph
        tempfile tmpgraph
        local graphfile "`tmpgraph'.png"
        
        * Determine which graph to export
        if "`graphname'" != "" {
            * Export named graph
            capture graph export "`graphfile'", name(`graphname') as(png) width(`width') replace
            if _rc != 0 {
                di as error "Error exporting graph '`graphname''. Graph may not exist."
                exit _rc
            }
        }
        else {
            * Export default Graph
            capture graph export "`graphfile'", as(png) width(`width') replace
            if _rc != 0 {
                di as error "Error exporting default graph. Graph may not exist."
                exit _rc
            }
        }
    }

    /* -------------------------------------------------------------------------
       4. Construct Headers
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
       5. Execution based on OS
       ------------------------------------------------------------------------- */
    if c(os) == "Windows" {
        local ps_headers ""
        if `"`title'"' != ""    local ps_headers `ps_headers' "Title"='`title''; 
        if `"`priority'"' != "" local ps_headers `ps_headers' "Priority"='`priority''; 
        if `"`tags'"' != ""     local ps_headers `ps_headers' "Tags"='`tags''; 
        if `"`delay'"' != ""    local ps_headers `ps_headers' "Delay"='`delay''; 
        
        if `"`ps_headers'"' != "" local ps_header_cmd -Headers @{`ps_headers'}
        
        if "`graphfile'" != "" {
            * Upload graph file with message header
            local ps_message = subinstr(`"`message'"', "'", "''", .)
            shell powershell -NoProfile -Command "$headers = @{`ps_headers' 'Message'='`ps_message''}; Invoke-RestMethod -Uri 'https://ntfy.sh/`final_topic'' -Method Put -InFile '`graphfile'' -Headers $headers"
        }
        else {
            * Send text message
            local ps_message = subinstr(`"`message'"', "'", "''", .)
            shell powershell -NoProfile -Command "Invoke-RestMethod -Uri 'https://ntfy.sh/`final_topic'' -Method Post -Body '`ps_message'' `ps_header_cmd'"
        }
    }
    else {
        if "`graphfile'" != "" {
            * Upload graph file with message header using curl -T
            local curl_cmd curl -s `headers' -H "Message: `message'" -T "`graphfile'" ntfy.sh/`final_topic' >/dev/null 2>&1 &
            
            * Escape any single quotes inside the command
            local curl_cmd = subinstr(`"`curl_cmd'"', "'", "'\''", .)
            
            * Execute using sh -c '...'
            shell sh -c '`curl_cmd''
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
    }    
    
    di as txt "Notification sent to ntfy.sh/`final_topic'"
end