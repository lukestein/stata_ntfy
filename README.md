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

## Setup (Optional)

You can set a **default topic** so you don't have to type it every time. This saves the preference to your personal Stata directory.

```stata
ntfy_set my_secret_topic
```


## Usage

### 1. Using a Default Topic

If you have run `ntfy_set`, you can just type a message:

```stata
ntfy "Regression analysis finished"

```

### 2. Explicit Topic

You can send to a specific topic (overriding the default) by providing it as the first argument:

```stata
ntfy other_topic "This goes to a different channel"

```

### 3. Advanced Options

Add titles, priorities, tags (emojis), or delays.

```stata
ntfy "Code failed to converge", title("Stata Error") priority(high) tags(warning)

```

## Syntax

```stata
ntfy [topic] ["message"] [, options]

```

| Option | Description |
| --- | --- |
| `title(string)` | Bold title displayed at the top of the notification. |
| `priority(string)` | Sets priority (`min`, `low`, `default`, `high`, `urgent`). |
| `tags(string)` | Comma-separated emojis or tags (e.g., `warning`, `tada`). |
| `delay(string)` | Schedule delivery (e.g., `10m`, `9am`, `tomorrow`). |
| `topic(string)` | Explicitly specify the target topic (alternative to positional argument). |

## Workflow Example

Use it to notify you of success or failure after a long job.

```stata
capture noise do my_analysis.do

if _rc == 0 {
    ntfy "Success: Model converged", tags(tada)
}
else {
    ntfy "Error: Script failed", tags(error) priority(high)
}

```


## Alternatives

Inspired by [statapush](https://github.com/wschpero/statapush) which uses [Pushbullet](http://pushbullet.com/), [Pushover](https://pushover.net/), or [IFTTT](https://ifttt.com/) rather than [ntfy.sh](https://ntfy.sh)


## Author

**[Luke Stein](https://lukestein.com)**
