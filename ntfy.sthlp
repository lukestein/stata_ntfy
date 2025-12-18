{smcl}
{* *! version 1.3.0  18dec2025}{...}
{viewerjumpto "Syntax" "ntfy##syntax"}{...}
{viewerjumpto "Description" "ntfy##description"}{...}
{viewerjumpto "Options" "ntfy##options"}{...}
{viewerjumpto "Examples" "ntfy##examples"}{...}
{title:Title}

{phang}
{bf:ntfy} {hline 2} Send notifications to ntfy.sh from Stata

{title:Syntax}

{p 8 17 2}
{cmdab:ntfy}
[{it:topic}]
[{it:"message"}]
[{cmd:,} {it:options}]

{p 8 17 2}
{cmdab:ntfy_set}
{it:default_topic}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt t:itle(string)}}notification title{p_end}
{synopt:{opt p:riority(string)}}priority level (min, low, default, high, urgent){p_end}
{synopt:{opt tags(string)}}comma-separated list of tags or emojis{p_end}
{synopt:{opt delay(string)}}delay delivery (e.g., "10m", "9am"){p_end}
{synopt:{opt topic(string)}}explicitly specify topic (overrides other logic){p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ntfy} sends a push notification to {browse "https://ntfy.sh":ntfy.sh} using standard HTTP requests. 
It is designed to be lightweight and platform-independent.

{pstd}
On {bf:Windows}, it uses PowerShell (Invoke-RestMethod).{break}
On {bf:Mac/Linux}, it uses cURL (shell curl).

{pstd}
{cmd:ntfy_set} saves a default topic to your personal adopath preferences. 
Once set, you can call {cmd:ntfy} with just a message, and it will route to your default topic automatically.

{marker options}{...}
{title:Options}

{phang}
{opt title(string)} specifies the bold title displayed at the top of the notification.

{phang}
{opt priority(string)} sets the notification priority (affects sound/vibration). Valid values: {it:min}, {it:low}, {it:default}, {it:high}, {it:urgent}.

{phang}
{opt tags(string)} adds emojis or text tags. Examples: {it:warning}, {it:tada}, {it:chart_with_upwards_trend}.

{phang}
{opt delay(string)} schedules the notification for later. Examples: "30s", "10m", "tomorrow".

{phang}
{opt topic(string)} forces the notification to go to this specific topic, ignoring defaults or other arguments.


{marker examples}{...}
{title:Examples}

{pstd}1. Set a default topic (do this once):{p_end}
{phang2}{cmd:. ntfy_set my_secret_topic}{p_end}

{pstd}2. Send a simple message (uses default topic):{p_end}
{phang2}{cmd:. ntfy "Regression analysis finished"}{p_end}

{pstd}3. Override the default topic for a specific message:{p_end}
{phang2}{cmd:. ntfy other_topic "This goes to a different channel"}{p_end}

{pstd}High priority error alert with a title and emoji:{p_end}
{phang2}{cmd:. ntfy "Code failed to converge", title("Stata Error") priority(high) tags(warning)}{p_end}

{pstd}Using in a robust workflow:{p_end}
{phang2}{cmd:. capture noise do my_analysis.do}{p_end}
{phang2}{cmd:. if _rc == 0 ntfy "Success", tags(tada)}{p_end}
{phang2}{cmd:. else ntfy "Fail", tags(error) priority(high)}{p_end}


{title:Author}

{pstd}Luke Stein{break}
https://github.com/lukestein/stata_ntfy
