{smcl}
{* *! version 1.1.0  18dec2025}{...}
{viewerjumpto "Syntax" "ntfy##syntax"}{...}
{viewerjumpto "Description" "ntfy##description"}{...}
{viewerjumpto "Options" "ntfy##options"}{...}
{viewerjumpto "Examples" "ntfy##examples"}{...}
{title:Title}

{phang}
{bf:ntfy} {hline 2} Send notifications to ntfy.sh from Stata

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:ntfy}
{it:topic}
[{it:"message"}]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt t:itle(string)}}notification title{p_end}
{synopt:{opt p:riority(string)}}priority level (min, low, default, high, urgent){p_end}
{synopt:{opt tags(string)}}comma-separated list of tags or emojis{p_end}
{synopt:{opt delay(string)}}delay delivery (e.g., "10m", "9am"){p_end}
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

{marker options}{...}
{title:Options}

{phang}
{opt title(string)} specifies the bold title displayed at the top of the notification.

{phang}
{opt priority(string)} sets the notification priority. 
Levels map to notification behaviors (colors, vibration, sound) on the ntfy mobile app.
Valid values are: {it:min}, {it:low}, {it:default}, {it:high}, {it:urgent}.

{phang}
{opt tags(string)} adds emojis or text tags to the notification. 
Common tags include: {it:warning}, {it:error}, {it:tada}, {it:chart_with_upwards_trend}.

{phang}
{opt delay(string)} schedules the notification to be sent later. 
Examples: "30s", "10m", "9am", "tomorrow".

{marker examples}{...}
{title:Examples}

{pstd}Basic usage (message is optional; defaults to "Stata job completed."):{p_end}
{phang2}{cmd:. ntfy my_secret_topic}{p_end}

{pstd}With a message:{p_end}
{phang2}{cmd:. ntfy my_secret_topic "Regression analysis finished"}{p_end}
{phang2}{cmd:. ntfy my_secret_topic Regressions done}{p_end}

{pstd}High priority error alert with a title and emoji:{p_end}
{phang2}{cmd:. ntfy my_secret_topic "Code failed to converge", title("Stata Error") priority(high) tags(warning)}{p_end}

{pstd}Using in a robust workflow:{p_end}
{phang2}{cmd:. capture noise do my_analysis.do}{p_end}
{phang2}{cmd:. if _rc == 0 ntfy my_topic "Success", tags(tada)}{p_end}
{phang2}{cmd:. else ntfy my_topic "Fail", tags(error) priority(high)}{p_end}

{title:Author}

{pstd}Luke Stein{break}
https://github.com/lukestein/stata_ntfy
