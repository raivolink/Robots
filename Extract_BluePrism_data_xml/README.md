#   Extract BluePrism data xml
Robot parses Blue Prism files and extracts data. Currently extracts sheets.
Robot steps are:
```robot
*** Tasks ***
Extract Data From File
    ${root}=	Parse XML	${XML}
    ${XML_DATA}  Create Table For Process
    ${XML_DATA}  Get SubSheet Id And Name   ${XML_DATA}
    ${XML_DATA}  Get Subsheet Descriptions  ${XML_DATA}
    ${children}=    Get Elements  ${XML}   xpath=*[@type="SubSheet"]
    Log    ${children}
    Filter empty rows    ${XML_DATA}
    Create Markdown Document    ${XML_DATA}
    Write table to CSV    ${XML_DATA}    ${OUTPUT_DIR}${/}xml.csv
```