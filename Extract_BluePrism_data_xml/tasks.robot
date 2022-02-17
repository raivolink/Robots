*** Settings ***
Documentation   Robot to extract data from Blue Prism files
...             works both bpprocess and xml
Library         XML
Library         RPA.Tables
Library         RPA.Desktop
Library         RPA.FileSystem


*** Variables ***
${XML}               %{XML_2}
${XML_DATA}          {}
${MARKDOWN_OUT}      devdocs${/}Example.MD

*** Keywords ***
Create Table For Process
    ${data_table}       Create table
    Add table column    ${data_table}    name=ID
    Add table column    ${data_table}    name=Key
    Add table column    ${data_table}    name=Description
    Add table column    ${data_table}    name=Sheet
    Add table column    ${data_table}    name=RunOrder
    [Return]            ${data_table}

*** Keywords ***
Get SubSheet Id And Name
    [Documentation]  Finds and extracts process sheet name and id
    ...              from process xml. Saves results to table
    [Arguments]  ${table}
    ${children} =	Get Elements	${XML}	xpath=subsheet
    FOR  ${index}  ${child}   IN ENUMERATE   @{children}
        Add Table Row   ${table}
        ${child_id}=  Get Element Attribute	${child}	subsheetid
        ${child_name}=  Get Element Text    ${child}    name
        Set table cell    ${table}    ${index}    LineID    ${index}
        Set table cell    ${table}    ${index}    Keyword    ${child_name}
        Set table cell    ${table}    ${index}    SheetID    ${child_id}
    END
    [Return]    ${table}


*** Keywords ***
Get Subsheet Descriptions
    [Documentation]  Finds process sheet descriptions and add them to
    ...              sheet line.
    [Arguments]  ${table}
    ${children}=    Get Elements  ${XML}   xpath=*[@type="SubSheetInfo"]
    FOR  ${index}  ${child}   IN ENUMERATE   @{children}
        ${child_id}=  Get Element Text	${child}	subsheetid
        ${success}  ${child_name}=  Run Keyword And Ignore Error
        ...                         Get Element Text   ${child}    narrative
        IF   "${success}" == "PASS"
            @{rows}=    Find table rows  ${table}    SheetID  ==   ${child_id}
            FOR    ${row}    IN    @{rows}
                Set table cell    ${table}    ${row}[LineID]    Description    ${child_name}
            END
        END
    END
    [Return]    ${table}
*** Keywords ***
Create Markdown Document
    [Arguments]  ${table}
    ${process_name}=    Get Element Attribute    ${XML}    name
    ${narrative}=   Get Element Attribute    ${XML}    narrative
    Create File    ${MARKDOWN_OUT}    overwrite=True
    Append To File    ${MARKDOWN_OUT}     \# ${process_name}${\n}
    Append To File    ${MARKDOWN_OUT}     ${narrative}${\n}
    FOR    ${elem}    IN    @{table}
        Append To File    ${MARKDOWN_OUT}     \## ${elem}[Keyword]${\n}
        Log To Console     ${elem}[Description]
        ${success}  ${decription_length}=  Run Keyword And Ignore Error
        ...                         Get Length    ${elem}[Description]
        IF    "${success}" == "PASS"
            Append To File    ${MARKDOWN_OUT}    ${elem}[Description]${\n}
        END
    END

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
