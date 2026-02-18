*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}                  http://localhost:3001/report-incident/
${PROFILE_URL}          http://localhost:3001/profile
${BROWSER}              chrome

# Locators
${SELECT_TYPE}          xpath=//select
${INPUT_TITLE}          xpath=//input[@placeholder='Brief title of the incident']
${TEXTAREA_DETAIL}      xpath=//textarea
${INPUT_REPORT_AGAINST}  xpath=//input[contains(@placeholder,'User')]
${INPUT_URL}            xpath=//input[@type='url']
${SUBMIT_BUTTON}        xpath=//button[@type='submit']
${CANCEL_BUTTON}        xpath=//a[contains(text(),'Cancel')]

*** Test Cases ***

TC1: Passenger Submit Report Successfully
    [Documentation]    ทดสอบกรณีผู้โดยสารกรอกข้อมูลครบถ้วนและส่งรายงานสำเร็จ
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.7 seconds

    Wait Until Element Is Visible    ${SELECT_TYPE}    10s
    Select From List By Label    ${SELECT_TYPE}    Driver Behavior Issue
    Input Text    ${INPUT_TITLE}    คนขับขับรถเร็วและอันตราบ
    Input Text    ${TEXTAREA_DETAIL}    พนักงานขับรถเร็วเกินกำหนดและพูดจาไม่สุภาพ ทำให้รู้สึกไม่ปลอดภัย
    Input Text    ${INPUT_REPORT_AGAINST}    Driver_001
    
    Click Element    ${SUBMIT_BUTTON}
    Wait Until Page Contains    reported successfully    15s
    [Teardown]    Close Browser

TC2: Passenger did not fill in the Title
    [Documentation]    ทดสอบกรณีไม่กรอก Title (Browser ต้องดักด้วย required)
    Open Browser    ${URL}    ${BROWSER}
    Set Selenium Speed    0.5 seconds
    Select From List By Index    ${SELECT_TYPE}    1
    Input Text    ${TEXTAREA_DETAIL}    กรอกข้อมูลครบแต่ลืมกรอก Title
    Click Element    ${SUBMIT_BUTTON}
    Page Should Not Contain    reported successfully
    [Teardown]    Close Browser

TC3: Passenger did not fill in the Description
    [Documentation]    ทดสอบกรณีไม่กรอก Description
    Open Browser    ${URL}    ${BROWSER}
    Input Text    ${INPUT_TITLE} คนขับขับรถเร็วและอันตราย   
    Click Element    ${SUBMIT_BUTTON}
    Page Should Not Contain    reported successfully
    [Teardown]    Close Browser

TC4: Passenger did not choose Incident Type
    [Documentation]    ทดสอบกรณีไม่เลือกประเภทเหตุการณ์
    Open Browser    ${URL}    ${BROWSER}
    Input Text    ${INPUT_TITLE}    คนขับขับรถเร็วและอันตราย
    Input Text    ${TEXTAREA_DETAIL}    ลืมเลือกประเภทเหตุการณ์ใน Dropdown
    Click Element    ${SUBMIT_BUTTON}
    Page Should Not Contain    reported successfully
    [Teardown]    Close Browser


TC5: Invalid Attachment URL Format
    [Documentation]    ทดสอบการกรอก URL ผิดรูปแบบ
    Open Browser    ${URL}    ${BROWSER}
    Select From List By Index    ${SELECT_TYPE}    1
    Input Text    ${INPUT_TITLE}    Test URL Format
    Input Text    ${TEXTAREA_DETAIL}    รายละเอียดการทดสอบ URL
    Input Text    ${INPUT_URL}    invalid_link_format
    Click Element    ${SUBMIT_BUTTON}
    Page Should Not Contain    reported successfully
    [Teardown]    Close Browser

TC6: Character Limit Constraint (Maxlength)
    [Documentation]    ตรวจสอบขีดจำกัดตัวอักษร 100 ตัวใน Title
    Open Browser    ${URL}    ${BROWSER}
    ${LONG_TEXT}    Evaluate    "A" * 110
    Input Text    ${INPUT_TITLE}    ${LONG_TEXT}
    ${VALUE}    Get Element Attribute    ${INPUT_TITLE}    value
    ${LENGTH}    Get Length    ${VALUE}
    Should Be Equal As Integers    ${LENGTH}    100
    [Teardown]    Close Browser
TC7: Character Limit Constraint (Maxlength)
    [Documentation]    ตรวจสอบขีดจำกัดตัวอักษร 2000 ตัวใน Description
    Open Browser    ${URL}    ${BROWSER}
    ${LONG_TEXT}    Evaluate    "A" * 2010
    Input Text    ${INPUT_TITLE}    ${LONG_TEXT}
    ${VALUE}    Get Element Attribute    ${TEXTAREA_DETAIL}    value
    ${LENGTH}    Get Length    ${VALUE}
    Should Be Equal As Integers    ${LENGTH}    2000
    [Teardown]    Close Browser

