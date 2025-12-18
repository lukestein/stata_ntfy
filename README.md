# ntfy: Send notifications to ntfy.sh from Stata
`ntfy` is a lightweight Stata module to send push notifications to [ntfy.sh](https://ntfy.sh) using standard HTTP requests.


It is designed to be **platform-independent** and **dependency-light**. It does not require Python or external plugins; it uses native system tools:
* **Windows:** PowerShell (`Invoke-RestMethod`)
* **Mac/Linux:** cURL (`shell curl`)

## Installation

You can install the package directly from GitHub:

```stata
net install ntfy, from("https://raw.githubusercontent.com/lukestein/stata_ntfy/main") replace
```

## Syntax

```stata
ntfy topic ["message"] [, options]
```

* **topic**: The topic name on ntfy.sh (e.g., `my_secret_topic`).
* **message**: The body text of the notification. If omitted, defaults to "Stata job completed."

## Options

| Option | Description |
| --- | --- |
| `title(string)` | The bold title displayed at the top of the notification. |
| `priority(string)` | Sets notification priority (affects sound/vibration). Valid values: `min`, `low`, `default`, `high`, `urgent`. |
| `tags(string)` | Comma-separated list of emojis or tags (e.g., `warning`, `tada`). |
| `delay(string)` | Schedules the notification for later delivery (e.g., `10m`, `9am`). |

## Examples

**Basic usage** (defaults to generic completion message):

```stata
ntfy my_secret_topic
```

**With a specific message:**

```stata
ntfy my_secret_topic "Regression analysis finished"
```

**High priority alert with title and emoji:**

```stata
ntfy my_secret_topic "Code failed to converge", title("Stata Error") priority(high) tags(warning)
```

**Workflow Integration:**
Use it to notify you of success or failure after a long job.

```stata
capture noise do my_analysis.do

if _rc == 0 {
    ntfy my_topic "Success", tags(tada)
}
else {
    ntfy my_topic "Fail", tags(error) priority(high)
}
```


## Author

**[Luke Stein](https://lukestein.com)**
