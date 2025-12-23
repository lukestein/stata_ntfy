*! version 1.5.0  23dec2025
program define ntfy_get, rclass
    version 14
    
    * Ensure defaults are loaded
    if "$NTFY_TOPIC" == "" {
        capture program drop ntfy_prefs
        capture ntfy_prefs
    }
    
    * Check if a default topic is set
    if "$NTFY_TOPIC" != "" {
        di as txt "Default ntfy topic: " as result "$NTFY_TOPIC"
        
        * Also show where the preferences are stored
        local personal_dir : sysdir PERSONAL
        di as txt "Preferences file: `personal_dir'ntfy_prefs.ado"
        
        * Return the topic for programmatic use
        return local topic "$NTFY_TOPIC"
    }
    else {
        di as txt "No default ntfy topic is currently set."
        di as txt "Use {cmd:ntfy_set} to set a default topic."
        return local topic ""
    }
end
