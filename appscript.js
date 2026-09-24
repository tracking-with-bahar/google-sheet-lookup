// =====================================================
// CONFIGURATION
// =====================================================

const googleSheetId = "Your Google Sheet ID";

const googleSheetName = "Your Sheet Name";


// =====================================================
// MAIN
// =====================================================

function doGet(e) {

  try {

    const spreadsheet =
      SpreadsheetApp.openById(googleSheetId);

    const sheet =
      spreadsheet.getSheetByName(googleSheetName);

    if (!sheet) {
      return jsonResponse({
        success: false,
        error: "Google Sheet not found"
      });
    }


    const action =
      String(e.parameter.action || "save")
        .toLowerCase();


    // =================================================
    // SHEET INFORMATION
    // =================================================

    const lastRow =
      sheet.getLastRow();

    const lastColumn =
      sheet.getLastColumn();


    if (lastColumn < 1) {

      return jsonResponse({
        success: false,
        error: "No columns found in Google Sheet"
      });

    }


    // =================================================
    // HEADERS
    // =================================================

    const headers =
      sheet
        .getRange(1, 1, 1, lastColumn)
        .getDisplayValues()[0]
        .map(function(header) {
          return String(header).trim();
        });


    // =================================================
    // LOOKUP
    // =================================================

    if (action === "lookup") {

      // -----------------------------------------------
      // Lookup inputs
      // -----------------------------------------------

      const lookupColumn =
        String(
          e.parameter.lookupColumn || ""
        ).trim();

      const lookupValue =
        String(
          e.parameter.lookupValue || ""
        ).trim();

      const returnColumn =
        String(
          e.parameter.returnColumn || ""
        ).trim();


      // -----------------------------------------------
      // Validate lookup column
      // -----------------------------------------------

      if (!lookupColumn) {

        return jsonResponse({
          success: false,
          error: "Lookup column is required"
        });

      }


      // -----------------------------------------------
      // Validate lookup value
      // -----------------------------------------------

      if (!lookupValue) {

        return jsonResponse({
          success: false,
          error: "Lookup value is required"
        });

      }


      // -----------------------------------------------
      // Find lookup column
      // -----------------------------------------------

      const lookupColumnIndex =
        findHeaderIndex(
          headers,
          lookupColumn
        );


      if (lookupColumnIndex === -1) {

        return jsonResponse({
          success: false,
          error:
            "Lookup column not found: " +
            lookupColumn
        });

      }


      // -----------------------------------------------
      // Find return column if provided
      // -----------------------------------------------

      let returnColumnIndex = -1;


      if (returnColumn) {

        returnColumnIndex =
          findHeaderIndex(
            headers,
            returnColumn
          );


        if (returnColumnIndex === -1) {

          return jsonResponse({
            success: false,
            error:
              "Return column not found: " +
              returnColumn
          });

        }

      }


      // -----------------------------------------------
      // No data rows
      // -----------------------------------------------

      if (lastRow < 2) {

        return jsonResponse({
          success: true,
          found: false
        });

      }


      // -----------------------------------------------
      // Read sheet data
      // -----------------------------------------------

      const data =
        sheet
          .getRange(
            2,
            1,
            lastRow - 1,
            lastColumn
          )
          .getDisplayValues();


      // -----------------------------------------------
      // Normalize requested value
      // -----------------------------------------------

      const normalizedLookupValue =
        normalizeValue(
          lookupColumn,
          lookupValue
        );


      // -----------------------------------------------
      // Search newest → oldest
      // -----------------------------------------------

      for (
        let i = data.length - 1;
        i >= 0;
        i--
      ) {

        const storedValue =
          normalizeValue(
            lookupColumn,
            data[i][lookupColumnIndex]
          );


        if (
          storedValue ===
          normalizedLookupValue
        ) {

          // =========================================
          // RETURN SINGLE COLUMN
          // =========================================

          if (
            returnColumn &&
            returnColumnIndex !== -1
          ) {

            return jsonResponse({

              success: true,

              found: true,

              value:
                data[i][returnColumnIndex]

            });

          }


          // =========================================
          // RETURN COMPLETE ROW
          // =========================================

          const responseData = {};


          headers.forEach(
            function(header, index) {

              if (header) {

                responseData[header] =
                  data[i][index];

              }

            }
          );


          return jsonResponse({

            success: true,

            found: true,

            responseData:
              responseData

          });

        }

      }


      // -----------------------------------------------
      // No match
      // -----------------------------------------------

      return jsonResponse({

        success: true,

        found: false

      });

    }


    // =================================================
    // SAVE
    // =================================================

    const row =
      lastRow + 1;


    const newRow = [];


    headers.forEach(
      function(header) {

        const value =
          e.parameter[header] || "";

        newRow.push(value);

      }
    );


    sheet
      .getRange(
        row,
        1,
        1,
        lastColumn
      )
      .setValues([newRow]);


    return jsonResponse({

      success: true,

      action: "saved",

      data:
        Object.fromEntries(

          headers.map(
            function(header, index) {

              return [
                header,
                newRow[index]
              ];

            }
          )

        )

    });


  } catch (err) {

    return jsonResponse({

      success: false,

      error: err.toString()

    });

  }

}


// =====================================================
// FIND HEADER INDEX
// =====================================================

function findHeaderIndex(
  headers,
  columnName
) {

  const target =
    String(columnName)
      .trim()
      .toLowerCase();


  return headers.findIndex(
    function(header) {

      return (
        String(header)
          .trim()
          .toLowerCase() === target
      );

    }
  );

}


// =====================================================
// NORMALIZE VALUE
// =====================================================

function normalizeValue(
  field,
  value
) {

  if (
    value === undefined ||
    value === null
  ) {

    return "";

  }

  value =
    String(value).trim();


  const fieldName =
    String(field)
      .toLowerCase();


  if (
    fieldName.includes("email")
  ) {

    return value.toLowerCase();

  }

  if (
    fieldName.includes("phone") ||
    fieldName.includes("mobile")
  ) {

    return value.replace(/\D/g, "");

  }


  return value;

}


// =====================================================
// JSON RESPONSE
// =====================================================

function jsonResponse(data) {

  return ContentService
    .createTextOutput(
      JSON.stringify(data)
    )
    .setMimeType(
      ContentService.MimeType.JSON
    );

}
