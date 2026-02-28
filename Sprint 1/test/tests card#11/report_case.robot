*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${BASE_URL}          http://localhost:3001
${BROWSER}           chrome
${DRIVER_EMAIL}      driver@test.com
${DRIVER_PASSWORD}   123456
${INCIDENT_TITLE}    Automation Test Incident
${INCIDENT_DESC}     Test incident created by automation.

*** Test Cases ***
Driver Report Incident And Verify Status Flow
    Open Browser    ${BASE_URL}/login    ${BROWSER}
    Maximize Browser Window

    Go To    ${BASE_URL}/my-incidents
    Wait Until Page Contains    My Reported Incidents    10s

    Element Should Be Visible    xpath=//*[contains(text(),'Report New Incident')]
    Click Element    xpath=//*[contains(text(),'Report New Incident')]

    Click Element    xpath=//button[@type='submit']

    # ===== AC1: หลัง submit กลับมาหน้าแสดงผล =====
    Wait Until Page Contains    My Reported Incidents    10s

    # ===== ตรวจว่า incident ที่สร้างแสดงใน list =====
    Page Should Contain    ${INCIDENT_TITLE}

    # ===== AC2: ตรวจสอบสถานะของการรายงาน =====
    ${has_pending}=    Run Keyword And Return Status    Page Should Contain    Pending
    ${has_approved}=   Run Keyword And Return Status    Page Should Contain    Approved
    ${has_rejected}=   Run Keyword And Return Status    Page Should Contain    Rejected

    Should Be True    ${has_pending} or ${has_approved} or ${has_rejected}

    Close Browser
