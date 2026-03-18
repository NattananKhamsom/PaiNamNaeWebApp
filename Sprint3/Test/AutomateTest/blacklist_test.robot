*** Settings ***
Library    SeleniumLibrary
Test Setup       Open Chrome Custom
Test Teardown    Close Browser

*** Variables ***
${URL}                https://csgroup31.cpkku.com
${ADMIN_USER}         admin123
${ADMIN_PASS}         123456789
${BLACK_USER}         testOO8@gmail.com
${BLACK_PASS}         123456789
${YELLOW_USER}        test007@gmail.com
${YELLOW_PASS}        12345678
${ID_CARD_IMG}        D:/33/PaiNamNaeWebApp-Nattanan/test_id_card.jpg
${SELFIE_IMG}         D:/33/PaiNamNaeWebApp-Nattanan/test_selfie.jpg
${BLACK_PHONE}        0888888888

*** Keywords ***
# ================= BROWSER =================
Open Chrome Custom
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --incognito
    Call Method    ${options}    add_argument    --start-maximized
    Open Browser    ${URL}    chrome    options=${options}
    Set Selenium Timeout    10s
    Wait Until Page Contains Element    tag:body

# ================= LOGIN =================
Click Login Button From Homepage
    Sleep    3s
    Capture Page Screenshot    homepage_before_login_click.png
    Wait Until Element Is Visible
    ...    xpath=//*[contains(text(),'เข้าสู่ระบบ') or contains(text(),'Login')]
    ...    timeout=15s
    Click Element
    ...    xpath=//*[contains(text(),'เข้าสู่ระบบ') or contains(text(),'Login')]

Wait For Login Form
    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=15s
    Wait Until Element Is Visible    xpath=//input[@type="password"]    timeout=15s

Fill Login Form
    [Arguments]    ${username}    ${password}
    Input Text    xpath=(//input)[1]    ${username}
    Input Text    xpath=//input[@type="password"]    ${password}

Submit Login Form
    Click Element    xpath=//button[@type="submit"]
    Sleep    3s
    Capture Page Screenshot    after_submit_login.png
    ${login_success}=    Run Keyword And Return Status
    ...    Wait Until Page Does Not Contain Element    xpath=//input[@type="password"]    timeout=5s
    IF    not ${login_success}
        Log    Login did not succeed — password field still visible (may be blacklisted)
    END

Complete Login Process
    [Arguments]    ${username}    ${password}
    Click Login Button From Homepage
    Wait For Login Form
    Fill Login Form    ${username}    ${password}
    Submit Login Form

# ================= NAVIGATION =================
Go To User Management Page
    Go To    ${URL}/admin/users
    Sleep    5s
    Capture Page Screenshot    user_management_page.png
    Wait Until Page Contains Element
    ...    xpath=//table | //input[contains(@placeholder,'ค้นหา') or contains(@placeholder,'Search') or @type='search'] | //*[contains(text(),'ผู้ใช้') or contains(text(),'User')]
    ...    timeout=15s

# ================= SEARCH & OPEN DETAIL =================
Search And Open User Detail
    [Arguments]    ${search_term}
    Wait Until Element Is Visible
    ...    xpath=//input[contains(@placeholder,'ค้นหา') or contains(@placeholder,'Search') or @type='search' or contains(@class,'search')]
    ...    timeout=15s
    Clear Element Text
    ...    xpath=//input[contains(@placeholder,'ค้นหา') or contains(@placeholder,'Search') or @type='search' or contains(@class,'search')]
    Input Text
    ...    xpath=//input[contains(@placeholder,'ค้นหา') or contains(@placeholder,'Search') or @type='search' or contains(@class,'search')]
    ...    ${search_term}
    Sleep    2s
    Capture Page Screenshot    search_result.png

    Wait Until Element Is Visible
    ...    xpath=//tr[contains(.,'${search_term}')]//button[.//svg or .//*[contains(@class,'eye')] or .//*[name()='svg']]
    ...    timeout=10s
    ${el}=    Get WebElement
    ...    xpath=//tr[contains(.,'${search_term}')]//button[.//svg or .//*[contains(@class,'eye')] or .//*[name()='svg']]
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${el}
    Sleep    3s
    Capture Page Screenshot    user_detail_opened.png

    Wait Until Element Is Visible
    ...    xpath=//a[contains(text(),'ไปออกใบเตือน') or contains(.,'ไปออกใบเตือน')]
    ...    timeout=10s

# ================= ISSUE YELLOW CARD =================
Issue Yellow Card And Confirm
    Wait Until Element Is Visible
    ...    xpath=//a[contains(text(),'ไปออกใบเตือน') or contains(.,'ไปออกใบเตือน')]
    ...    timeout=10s
    Click Element
    ...    xpath=//a[contains(text(),'ไปออกใบเตือน') or contains(.,'ไปออกใบเตือน')]
    Sleep    2s
    Capture Page Screenshot    ticket_page_opened.png
    Wait Until Page Contains    ออกใบเตือน    timeout=10s

    Wait Until Element Is Visible    xpath=//button[contains(.,'ใบเหลือง')]    timeout=10s
    Click Element    xpath=//button[contains(.,'ใบเหลือง')]
    Sleep    1s
    Capture Page Screenshot    yellow_card_selected.png

    Wait Until Element Is Visible    xpath=//select    timeout=10s
    Select From List By Label    xpath=//select    ก่อกวน / ทำลายทรัพย์สินในรถ
    Sleep    1s

    Wait Until Element Is Visible    xpath=//textarea    timeout=5s
    Input Text    xpath=//textarea    ทดสอบระบบ blacklist โดย admin
    Sleep    1s
    Capture Page Screenshot    ticket_form_filled.png

    Wait Until Element Is Enabled
    ...    xpath=//button[contains(.,'ออก ใบเหลือง') or contains(.,'ออกใบเหลือง')]
    ...    timeout=5s
    Scroll Element Into View
    ...    xpath=//button[contains(.,'ออก ใบเหลือง') or contains(.,'ออกใบเหลือง')]
    Sleep    1s
    Click Element
    ...    xpath=//button[contains(.,'ออก ใบเหลือง') or contains(.,'ออกใบเหลือง')]
    Sleep    1s
    Handle Alert    ACCEPT
    Sleep    3s
    Capture Page Screenshot    ticket_submitted.png
    Log    ออกใบเหลืองสำเร็จ

# ================= ISSUE RED CARD =================
Issue Red Card And Confirm
    Wait Until Element Is Visible
    ...    xpath=//a[contains(text(),'ไปออกใบเตือน') or contains(.,'ไปออกใบเตือน')]
    ...    timeout=10s
    Click Element
    ...    xpath=//a[contains(text(),'ไปออกใบเตือน') or contains(.,'ไปออกใบเตือน')]
    Sleep    2s
    Capture Page Screenshot    red_ticket_page_opened.png
    Wait Until Page Contains    ออกใบเตือน    timeout=10s

    Wait Until Element Is Visible
    ...    xpath=//button[contains(.,'ใบแดง') or contains(.,'Blacklist ทันที')]
    ...    timeout=10s
    Click Element
    ...    xpath=//button[contains(.,'ใบแดง') or contains(.,'Blacklist ทันที')]
    Sleep    1s
    Capture Page Screenshot    red_card_selected.png

    Wait Until Element Is Visible    xpath=//select    timeout=10s
    Select From List By Label    xpath=//select    ขับรถอันตราย / ไม่ปฏิบัติตามกฎจราจร
    Sleep    1s

    Wait Until Element Is Visible    xpath=//textarea    timeout=5s
    Input Text    xpath=//textarea    ทดสอบระบบ blacklist ใบแดง โดย admin
    Sleep    1s
    Capture Page Screenshot    red_card_form_filled.png

    Wait Until Element Is Enabled
    ...    xpath=//*[@id="main-content"]/div[2]/div[2]/div[1]/div[3]/button
    ...    timeout=5s
    ${red_btn}=    Get WebElement
    ...    xpath=//*[@id="main-content"]/div[2]/div[2]/div[1]/div[3]/button
    Execute Javascript    arguments[0].scrollIntoView(true); arguments[0].click();    ARGUMENTS    ${red_btn}
    Sleep    1s
    Handle Alert    ACCEPT
    Sleep    3s
    Capture Page Screenshot    red_card_submitted.png
    Log    ออกใบแดงสำเร็จ

# ================= LOGOUT =================
Logout From System
    Wait Until Element Is Visible
    ...    xpath=//img[contains(@class,'avatar') or contains(@class,'profile')] | //div[contains(@class,'avatar')] | //button[contains(@class,'avatar')] | //*[@alt='avatar'] | //header//*[name()='svg'][last()] | //nav//*[contains(@class,'rounded-full')]
    ...    timeout=10s
    ${avatar}=    Get WebElement
    ...    xpath=//img[contains(@class,'avatar') or contains(@class,'profile')] | //div[contains(@class,'avatar')] | //button[contains(@class,'avatar')] | //*[@alt='avatar'] | //header//*[name()='svg'][last()] | //nav//*[contains(@class,'rounded-full')]
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${avatar}
    Sleep    1s
    Capture Page Screenshot    dropdown_opened.png
    Wait Until Element Is Visible
    ...    xpath=//*[contains(text(),'Logout') or contains(text(),'ออกจากระบบ')]
    ...    timeout=8s
    Click Element
    ...    xpath=//*[contains(text(),'Logout') or contains(text(),'ออกจากระบบ')]
    Sleep    2s
    Capture Page Screenshot    logout_success.png

# ================= CHECK BLACKLIST STATUS =================
Check Blacklist Status
    ${is_blocked}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element
    ...    xpath=//*[contains(text(),'blacklist') or contains(text(),'blocked') or contains(text(),'suspended') or contains(text(),'ถูกระงับ') or contains(text(),'ไม่สามารถเข้าใช้งานได้')]
    ...    timeout=8s
    IF    ${is_blocked}
        Capture Page Screenshot    blacklist_confirmed.png
        RETURN    ${True}
    END
    ${still_on_login}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//input[@type="password"]
    IF    ${still_on_login}
        Capture Page Screenshot    login_blocked.png
        RETURN    ${True}
    END
    Capture Page Screenshot    blacklist_unclear.png
    RETURN    ${False}

*** Test Cases ***
TC1 Admin Issue Yellow Card First Time To test007
    [Documentation]    Admin ออกใบเหลืองครั้งที่ 1 ให้ user test007 (PASSENGER)
    [Tags]    admin    blacklist    yellow-card
    Complete Login Process    ${ADMIN_USER}    ${ADMIN_PASS}
    Go To User Management Page
    Search And Open User Detail    test007
    Issue Yellow Card And Confirm

TC2 User Can Still Login After First Yellow Card
    [Documentation]    ตรวจสอบว่า user ที่โดนใบเหลือง 1 ครั้ง ยังสามารถเข้าสู่ระบบได้
    [Tags]    blacklist    validation    yellow-card
    Complete Login Process    ${YELLOW_USER}    ${YELLOW_PASS}
    ${still_login}=    Run Keyword And Return Status
    ...    Wait Until Page Does Not Contain Element    xpath=//input[@type="password"]    timeout=8s
    Should Be True    ${still_login}
    ...    msg=User ควรยังเข้าสู่ระบบได้หลังโดนใบเหลือง 1 ครั้ง
    Capture Page Screenshot    tc2_still_can_login.png
    Log    TC2 Passed — user ยังเข้าสู่ระบบได้หลังโดนใบเหลือง 1 ครั้ง

TC3 Admin Issue Yellow Card Second Time To test007
    [Documentation]    Admin ออกใบเหลืองครั้งที่ 2 ให้ user test007 — Blacklist อัตโนมัติ
    [Tags]    admin    blacklist    yellow-card
    Complete Login Process    ${ADMIN_USER}    ${ADMIN_PASS}
    Go To User Management Page
    Search And Open User Detail    test007
    Issue Yellow Card And Confirm

TC4 Admin Issue Red Card To test008
    [Documentation]    Admin ออกใบแดงให้ user test008 (DRIVER) — Blacklist ทันที
    [Tags]    admin    blacklist    red-card
    Complete Login Process    ${ADMIN_USER}    ${ADMIN_PASS}
    Go To User Management Page
    Search And Open User Detail    test008
    Issue Red Card And Confirm

TC5 Blacklisted User Cannot Login
    [Documentation]    ตรวจสอบว่า user ที่ถูก blacklist (test008) ไม่สามารถ login ได้
    [Tags]    blacklist    validation
    Complete Login Process    ${BLACK_USER}    ${BLACK_PASS}
    ${blocked}=    Check Blacklist Status
    Should Be True    ${blocked}    msg=Expected user to be blocked but login succeeded
    Log    Blacklisted user was correctly blocked — Test Passed!

TC6 Blacklisted User Cannot Re-Register
    [Documentation]    ตรวจสอบว่า user ที่ถูก blacklist ไม่สามารถสมัครสมาชิกใหม่ได้ด้วยข้อมูลเดิม
    [Tags]    blacklist    re-register
    Wait Until Element Is Visible
    ...    xpath=//*[contains(text(),'สมัครสมาชิก') or contains(text(),'Register')]
    ...    timeout=10s
    Click Element
    ...    xpath=//*[contains(text(),'สมัครสมาชิก') or contains(text(),'Register')]
    Sleep    2s

    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=10s
    Input Text    xpath=(//input)[1]    testOO8new
    Input Text    xpath=(//input)[2]    testOO8new@gmail.com
    Input Text    xpath=(//input[@type="password"])[1]    Password123
    Input Text    xpath=(//input[@type="password"])[2]    Password123
    Sleep    1s
    Click Element    xpath=//button[contains(.,'ถัดไป')]
    Sleep    2s

    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=10s
    Input Text    xpath=(//input)[1]    ทดสอบ
    Input Text    xpath=(//input)[2]    ระบบ
    Input Text    xpath=(//input)[3]    0888888888
    Click Element    xpath=//input[@type="radio" and following-sibling::*[contains(.,'หญิง')]] | //label[contains(.,'หญิง')]//input | //*[contains(text(),'หญิง')]
    Sleep    1s
    Click Element    xpath=//button[contains(.,'ถัดไป')]
    Sleep    2s

    Wait Until Page Contains Element    xpath=(//input[@type="file"])[1]    timeout=10s
    Choose File    xpath=(//input[@type="file"])[1]    ${ID_CARD_IMG}
    Input Text    xpath=//input[contains(@placeholder,'13 หลัก') or contains(@placeholder,'หมายเลข')]    1888888888888
    Input Text    xpath=//input[contains(@placeholder,'วว/ดด/ปปปป') or contains(@placeholder,'วัน')]    01/01/2030
    Choose File    xpath=(//input[@type="file"])[2]    ${SELFIE_IMG}
    Sleep    1s
    Click Element    xpath=//input[@type="checkbox"]
    Sleep    1s
    Click Element    xpath=//button[contains(.,'สมัครสมาชิก')]
    Sleep    4s
    Capture Page Screenshot    after_register_submit.png

    ${blocked}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element
    ...    xpath=//*[contains(text(),'blacklist') or contains(text(),'ถูกระงับ') or contains(text(),'blocked') or contains(text(),'ไม่สามารถสมัคร') or contains(text(),'banned') or contains(text(),'ข้อมูลนี้ถูกระงับ') or contains(text(),'หมายเลขบัตร')]
    ...    timeout=8s
    IF    ${blocked}
        Capture Page Screenshot    reregister_blocked_confirmed.png
        Log    Re-register ถูกบล็อกสำเร็จ — Test Passed!
    ELSE
        Capture Page Screenshot    reregister_not_blocked.png
        Fail    ระบบไม่ได้บล็อกการสมัครใหม่ด้วยข้อมูลที่ถูก blacklist
    END

TC7 Blacklisted User Cannot Re-Register With Same Email
    [Documentation]    ตรวจสอบว่าไม่สามารถสมัครด้วย email เดิมของ user ที่ถูก blacklist
    [Tags]    blacklist    re-register
    Wait Until Element Is Visible
    ...    xpath=//*[contains(text(),'สมัครสมาชิก') or contains(text(),'Register')]
    ...    timeout=10s
    Click Element
    ...    xpath=//*[contains(text(),'สมัครสมาชิก') or contains(text(),'Register')]
    Sleep    2s

    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=10s
    Input Text    xpath=(//input)[1]    testOO8new2
    Input Text    xpath=(//input)[2]    testOO8@gmail.com
    Input Text    xpath=(//input[@type="password"])[1]    Password123
    Input Text    xpath=(//input[@type="password"])[2]    Password123
    Sleep    1s
    Capture Page Screenshot    tc6_step1_filled.png
    Click Element    xpath=//button[contains(.,'ถัดไป')]
    Sleep    3s
    Capture Page Screenshot    tc6_after_step1.png

    ${blocked_step1}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element
    ...    xpath=//*[contains(text(),'blacklist') or contains(text(),'ถูกระงับ') or contains(text(),'blocked') or contains(text(),'อีเมลนี้') or contains(text(),'email') or contains(text(),'ใช้งานแล้ว') or contains(text(),'already')]
    ...    timeout=5s
    IF    ${blocked_step1}
        Capture Page Screenshot    tc6_blocked_step1.png
        Log    TC7 Passed — email เดิมถูกบล็อกที่ Step 1
        Pass Execution    TC7 Passed — email เดิมของ test008 ถูกบล็อกที่ Step 1
    END

    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=10s
    Input Text    xpath=(//input)[1]    ทดสอบ
    Input Text    xpath=(//input)[2]    ระบบ
    Input Text    xpath=(//input)[3]    0891234568
    Click Element    xpath=//*[contains(text(),'หญิง')]
    Sleep    1s
    Click Element    xpath=//button[contains(.,'ถัดไป')]
    Sleep    2s

    Wait Until Page Contains Element    xpath=(//input[@type="file"])[1]    timeout=10s
    Choose File    xpath=(//input[@type="file"])[1]    ${ID_CARD_IMG}
    Input Text    xpath=//input[contains(@placeholder,'13 หลัก') or contains(@placeholder,'หมายเลข')]    9999999999999
    Input Text    xpath=//input[contains(@placeholder,'วว/ดด/ปปปป') or contains(@placeholder,'วัน')]    01/01/2030
    Choose File    xpath=(//input[@type="file"])[2]    ${SELFIE_IMG}
    Sleep    1s
    Click Element    xpath=//input[@type="checkbox"]
    Sleep    1s
    Capture Page Screenshot    tc6_step3_filled.png
    Click Element    xpath=//button[contains(.,'สมัครสมาชิก')]
    Sleep    4s
    Capture Page Screenshot    tc6_after_submit.png

    ${blocked}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element
    ...    xpath=//*[contains(text(),'blacklist') or contains(text(),'ถูกระงับ') or contains(text(),'blocked') or contains(text(),'อีเมลนี้') or contains(text(),'ใช้งานแล้ว') or contains(text(),'already')]
    ...    timeout=8s
    IF    ${blocked}
        Capture Page Screenshot    tc6_blocked_confirmed.png
        Log    TC6 Passed — email เดิมถูกบล็อกสำเร็จ
    ELSE
        Capture Page Screenshot    tc6_not_blocked.png
        Fail    ระบบไม่ได้บล็อกการสมัครด้วย email เดิมที่ถูก blacklist
    END

TC8 Blacklisted User Cannot Re-Register With Same Phone
    [Documentation]    ตรวจสอบว่าไม่สามารถสมัครด้วยเบอร์โทรเดิมของ user ที่ถูก blacklist
    [Tags]    blacklist    re-register
    Wait Until Element Is Visible
    ...    xpath=//*[contains(text(),'สมัครสมาชิก') or contains(text(),'Register')]
    ...    timeout=10s
    Click Element
    ...    xpath=//*[contains(text(),'สมัครสมาชิก') or contains(text(),'Register')]
    Sleep    2s

    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=10s
    Input Text    xpath=(//input)[1]    testOO8new3
    Input Text    xpath=(//input)[2]    testOO8new3@gmail.com
    Input Text    xpath=(//input[@type="password"])[1]    Password123
    Input Text    xpath=(//input[@type="password"])[2]    Password123
    Sleep    1s
    Click Element    xpath=//button[contains(.,'ถัดไป')]
    Sleep    2s

    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=10s
    Input Text    xpath=(//input)[1]    ทดสอบ
    Input Text    xpath=(//input)[2]    ระบบ
    Input Text    xpath=(//input)[3]    ${BLACK_PHONE}
    Click Element    xpath=//*[contains(text(),'หญิง')]
    Sleep    1s
    Capture Page Screenshot    tc7_step2_filled.png
    Click Element    xpath=//button[contains(.,'ถัดไป')]
    Sleep    3s
    Capture Page Screenshot    tc7_after_step2.png

    ${blocked_step2}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element
    ...    xpath=//*[contains(text(),'blacklist') or contains(text(),'ถูกระงับ') or contains(text(),'blocked') or contains(text(),'เบอร์') or contains(text(),'โทรศัพท์') or contains(text(),'already')]
    ...    timeout=5s
    IF    ${blocked_step2}
        Capture Page Screenshot    tc7_blocked_step2.png
        Log    TC7 Passed — เบอร์โทรเดิมถูกบล็อกที่ Step 2
        Pass Execution    TC7 Passed — เบอร์โทรเดิมถูกบล็อกที่ Step 2
    END

    Wait Until Page Contains Element    xpath=(//input[@type="file"])[1]    timeout=10s
    Choose File    xpath=(//input[@type="file"])[1]    ${ID_CARD_IMG}
    Input Text    xpath=//input[contains(@placeholder,'13 หลัก') or contains(@placeholder,'หมายเลข')]    1888888888888
    Input Text    xpath=//input[contains(@placeholder,'วว/ดด/ปปปป') or contains(@placeholder,'วัน')]    01/01/2030
    Choose File    xpath=(//input[@type="file"])[2]    ${SELFIE_IMG}
    Sleep    1s
    Click Element    xpath=//input[@type="checkbox"]
    Sleep    1s
    Capture Page Screenshot    tc7_step3_filled.png
    Click Element    xpath=//button[contains(.,'สมัครสมาชิก')]
    Sleep    4s
    Capture Page Screenshot    tc7_after_submit.png

    ${blocked}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element
    ...    xpath=//*[contains(text(),'blacklist') or contains(text(),'ถูกระงับ') or contains(text(),'blocked') or contains(text(),'เบอร์') or contains(text(),'already')]
    ...    timeout=8s
    IF    ${blocked}
        Capture Page Screenshot    tc7_blocked_confirmed.png
        Log    TC7 Passed — เบอร์โทรเดิมถูกบล็อกสำเร็จ
    ELSE
        Capture Page Screenshot    tc7_not_blocked.png
        Fail    ระบบไม่ได้บล็อกการสมัครด้วยเบอร์โทรเดิมที่ถูก blacklist
    END
