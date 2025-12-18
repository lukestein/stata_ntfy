*! version 1.1.0  18dec2025
program define ntfy_set
    version 14
    syntax anything(name=topic id="Default Topic")
    
    local topic = trim(`"`topic'"')
    
    * Locate the PERSONAL directory
    local personal_dir : sysdir PERSONAL
    
    * Create the prefs file
    capture file close fh
    quietly file open fh using "`personal_dir'ntfy_prefs.ado", write text replace
    file write fh "*! Auto-generated ntfy preferences" _n
    file write fh "program define ntfy_prefs" _n
    file write fh "    global NTFY_TOPIC `topic'" _n
    file write fh "end" _n
    file close fh
    
    * Force reload of the new settings
    capture program drop ntfy_prefs
    ntfy_prefs
    
    di as txt "Default ntfy topic set to: " as result "$NTFY_TOPIC"
    di as txt "Settings saved to: `personal_dir'ntfy_prefs.ado"
end