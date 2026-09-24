# Google Sheets Lookup Variable for sGTM

A reusable **Google Sheets Lookup Variable for Server-Side Google Tag Manager (sGTM)**.

It connects sGTM with Google Sheets through a Google Apps Script Web App and supports both **lookup and write operations**.

## Features

* **Lookup Data** — Search by column and value, then return a specific field or the full row.
* **Write Data** — Send dynamic sGTM data to a new Google Sheets row.
* **Specific Event** — Control when the variable runs, such as `generate_lead` or `form_submitted`.
* **Dynamic Columns** — Add or remove Google Sheet columns without redeploying the Apps Script.
* **Email & Phone Matching** — Supports normalized email and phone lookups.

## Example

A simple use case is looking up a GCLID using an email or phone number and using that value somewhere else.

```text
sGTM → Apps Script Web App → Google Sheets
                         ↓
                       GCLID
```

## Setup

### 1. Google Sheet

Create a sheet with your required column headers.

Example:

```text
Customer Phone | Customer GCLID | Customer Email
```

### 2. Apps Script

Open:

**Extensions → Apps Script**

Add the provided Apps Script from the <a> href="https://github.com/tracking-with-bahar/google-sheet-lookup/blob/main/appscript%20.js" appscript </a> file on this GitHub repository and update:

```javascript
const googleSheetId = "YOUR_GOOGLE_SHEET_ID";
const googleSheetName = "Sheet1";
```

Deploy it as a **Web App** and copy the Web App URL.

### 3. sGTM  

Import the variable template and add your Web App URL.

For lookup:

```text
Operation: Lookup Data
Lookup Column: Customer Email
Lookup Value: {{email}}
Return Column: Customer GCLID
```

For writing data, map your sGTM variables to the corresponding Google Sheet columns.

## Why I Built It

Sometimes you need a simple lookup or data storage layer in an sGTM setup without introducing a full database.

This template provides a practical way to use Google Sheets for those cases.

## Requirements

* Server-Side Google Tag Manager
* Google Sheet
* Google Apps Script Web App

If you find a useful sGTM use case for it, feel free to share it.
