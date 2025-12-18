*! version 1.0.0  18dec2025
program define ntfy_set
    version 14
    syntax anything(name=topic id="Default Topic")
    
    * Clean the topic name
    local topic = trim(`"`topic'"')
    
    * Locate the PERSONAL directory
    local personal_dir : sysdir PERSONAL
    
    * Create the prefs file
    capture file close fh
    file open fh using "`personal_dir'ntfy_prefs.ado", write text replace
    file write fh "*! Auto-generated ntfy preferences" _n
    file write fh "program define ntfy_prefs" _n
    file write fh "    global NTFY_TOPIC `topic'" _n
    file write fh "end" _n
    file close fh
    
    * Load it immediately for this session
    discard
    ntfy_prefs
    
    di as txt "Default ntfy topic set to: " as result "$NTFY_TOPIC"
    di as txt "Settings saved to: `personal_dir'ntfy_prefs.ado"
end
