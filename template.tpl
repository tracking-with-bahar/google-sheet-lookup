___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Google Sheet Lookup",
  "description": "Look up or write data in Google Sheets from server-side GTM. Search by column and value, return a specific field or the full row, and write dynamic event data to new rows.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "webURL",
    "displayName": "Web App URL",
    "simpleValueType": true,
    "help": "Google Apps Script \u003cstrong\u003eWeb App URL\u003c/strong\u003e used to read or write data to Google Sheets.",
    "valueHint": "https://script.google.com/"
  },
  {
    "type": "TEXT",
    "name": "firedEvent",
    "displayName": "Specific  Event",
    "simpleValueType": true,
    "valueHint": "generate_lead",
    "help": "Controls when this variable runs. It runs only when the specified event occurs, such as \u003cstrong\u003egenerate_lead\u003c/strong\u003e or \u003cstrong\u003eform_submitted\u003c/strong\u003e."
  },
  {
    "type": "RADIO",
    "name": "radioButton",
    "displayName": "Operation",
    "radioItems": [
      {
        "value": "lookupdata",
        "displayValue": "Lookup Data"
      },
      {
        "value": "writedata",
        "displayValue": "Write Data"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "lookupColumn",
    "displayName": "Lookup Column",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "radioButton",
        "paramValue": "lookupdata",
        "type": "EQUALS"
      }
    ],
    "valueHint": "Customer Email",
    "help": "The Google Sheet column to search."
  },
  {
    "type": "TEXT",
    "name": "lookupColumnValue",
    "displayName": "Lookup Value",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "radioButton",
        "paramValue": "lookupdata",
        "type": "EQUALS"
      }
    ],
    "valueHint": "test@example.com",
    "help": "The value to search for in the selected column."
  },
  {
    "type": "GROUP",
    "name": "parseColumn",
    "displayName": "Return a Single Column",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "returnCheck",
        "checkboxText": "Return a Specific Column",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "returnColumn",
        "displayName": "Return Column",
        "simpleValueType": true,
        "enablingConditions": [
          {
            "paramName": "returnCheck",
            "paramValue": true,
            "type": "EQUALS"
          }
        ],
        "valueHint": "Customer GCLID"
      }
    ],
    "enablingConditions": [
      {
        "paramName": "radioButton",
        "paramValue": "lookupdata",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "writedata",
    "displayName": "Write Data",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "columnTable",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Column Name",
            "name": "columnname",
            "type": "TEXT",
            "valueHint": "Customer Email"
          },
          {
            "defaultValue": "",
            "displayName": "Column Value",
            "name": "columnvalue",
            "type": "TEXT"
          }
        ],
        "newRowButtonText": "Add Column"
      }
    ],
    "enablingConditions": [
      {
        "paramName": "radioButton",
        "paramValue": "writedata",
        "type": "EQUALS"
      }
    ],
    "help": "Add the Google Sheet column names and the values you want to write."
  }
]


___SANDBOXED_JS_FOR_SERVER___

const sendHttpRequest = require('sendHttpRequest');
const logToConsole = require('logToConsole');
const makeString = require('makeString');
const JSON = require('JSON');
const getEventData = require('getEventData');
const encodeUriComponent = require('encodeUriComponent');
const Object = require('Object');

const timeout = 6000;

const eventName = getEventData('event_name');

if (eventName && eventName !== data.firedEvent) {
  return;
}

let columndata = {};

if (data.radioButton === 'writedata') {

  data.columnTable.forEach(function(row) {

    const columnName =
      makeString(row.columnname);

    const columnValue =
      makeString(row.columnvalue);

    if (columnName) {

      columndata[columnName] =
        columnValue;

    }

  });

}

let url = data.webURL;

if (data.radioButton === 'writedata') {

  url += '?action=save';

  Object.keys(columndata).forEach(
    function(columnName) {

      url +=
        '&' +
        encodeUriComponent(columnName) +
        '=' +
        encodeUriComponent(
          columndata[columnName]
        );

    }
  );

}

else {

  const lookupColumn =
    makeString(data.lookupColumn);

  const lookupValue =
    makeString(data.lookupColumnValue);

  const returnColumn =
    makeString(data.returnColumn);

  url +=
    '?action=lookup' +
    '&lookupColumn=' +
    encodeUriComponent(lookupColumn) +
    '&lookupValue=' +
    encodeUriComponent(lookupValue);

  if (
    data.returnCheck &&
    returnColumn &&
    returnColumn !== 'undefined'
  ) {

    url +=
      '&returnColumn=' +
      encodeUriComponent(returnColumn);

  }

}

return sendHttpRequest(url, {

  method: 'GET',

  timeout: timeout

}).then(function(res) {

  if (
    res.statusCode === 302 &&
    res.headers.location
  ) {

    return sendHttpRequest(
      res.headers.location,
      {
        method: 'GET',
        timeout: timeout
      }

    ).then(function(finalRes) {
      
      if (
        finalRes.statusCode >= 200 &&
        finalRes.statusCode < 300
      ) {

        const result =
          JSON.parse(finalRes.body);

        if (
          data.radioButton === 'writedata'
        ) {

          if (result.success === true) {

            return result.data;

          }

          return null;

        }

        if (
          result.success === true &&
          result.found === true
        ) {

          const returnColumn =
            makeString(data.returnColumn);

          if (
            data.returnCheck &&
            returnColumn &&
            returnColumn !== 'undefined'
          ) {

            return result.value;

          }

          return result.responseData;

        }

        return null;

      }

      return null;

    });

  }

  return null;

}).catch(function(error) {

  logToConsole(
    'REQUEST ERROR: ' +
    makeString(error)
  );

  return null;

});


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://script.google.com/"
              },
              {
                "type": 1,
                "string": "https://script.googleusercontent.com/"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "event_name"
              }
            ]
          }
        },
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 9/24/2026, 3:02:53 PM


