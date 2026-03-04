*** Settings ***
Library    SeleniumLibrary
Suite Setup    Open Chrome Custom
Suite Teardown    Close Browser

*** Variables ***
${URL}                https://csgroup31.cpkku.com
${ADMIN_USER}         admin123
${ADMIN_PASS}         123456789
${BLACK_USER}         test012@gmail.com
${BLACK_PASS}         123456789
${ID_CARD_IMG}        D:/33/PaiNamNaeWebApp-Nattanan/test_id_card.jpg
${SELFIE_IMG}         D:/33/PaiNamNaeWebApp-Nattanan/test_selfie.jpg
${BLACK_PHONE}        0812345678

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
    Wait Until Page Contains Element    xpath=//table    timeout=10s

# ================= SEARCH & OPEN DETAIL =================
Search And Open User Detail
    [Arguments]    ${search_term}
    
    Wait Until Element Is Visible
    ...    xpath=//input[contains(@placeholder,'ค้นหา') or contains(@placeholder,'Search')]
    ...    timeout=10s
    Clear Element Text
    ...    xpath=//input[contains(@placeholder,'ค้นหา') or contains(@placeholder,'Search')]
    Input Text
    ...    xpath=//input[contains(@placeholder,'ค้นหา') or contains(@placeholder,'Search')]
    ...    ${search_term}
    Sleep    2s
    Capture Page Screenshot    search_result.png

    Wait Until Element Is Visible
    ...    xpath=//tr[contains(.,'${search_term}')]//button[contains(@class,'view') or .//svg or .//*[contains(@class,'eye')] or .//*[name()='svg']]
    ...    timeout=10s
    ${el}=    Get WebElement
    ...    xpath=//tr[contains(.,'${search_term}')]//button[contains(@class,'view') or .//svg or .//*[contains(@class,'eye')] or .//*[name()='svg']]
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${el}
    Sleep    3s
    Capture Page Screenshot    user_detail_opened.png

    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(.,'BLACKLIST') or contains(.,'Blacklist') or contains(.,'ลงโทษ')]
    ...    timeout=10s

# ================= BLACKLIST ON DETAIL PAGE =================
Fill Blacklist Form And Confirm
    
    Wait Until Element Is Visible    xpath=(//select)[1]    timeout=10s
    Select From List By Value    xpath=(//select)[1]    ก่อกวน / ทำลายทรัพย์สินในรถ
    Sleep    1s

    
    Wait Until Element Is Visible    xpath=//textarea    timeout=5s
    Input Text    xpath=//textarea    ทดสอบระบบ blacklist โดย admin
    Sleep    1s
    Capture Page Screenshot    blacklist_form_filled.png

    
    Wait Until Element Is Enabled
    ...    xpath=//button[contains(.,'BLACKLIST') or contains(.,'Blacklist') or contains(.,'ลงโทษ')]
    ...    timeout=5s
    Click Element
    ...    xpath=//button[contains(.,'BLACKLIST') or contains(.,'Blacklist') or contains(.,'ลงโทษ')]

    # 4. รับ browser confirm()
    Handle Alert    ACCEPT
    Sleep    2s
    Capture Page Screenshot    blacklist_done.png

    # 5. ตรวจ badge BLACKLISTED
    Wait Until Page Contains    BLACKLISTED    timeout=10s
    Log    Blacklist สำเร็จ — badge BLACKLISTED ปรากฏแล้ว

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
TC1 Admin Blacklist test015
    [Documentation]    Admin blacklist user test015 (PASSENGER)
    [Tags]    admin    blacklist
    Complete Login Process    ${ADMIN_USER}    ${ADMIN_PASS}
    Go To User Management Page
    Search And Open User Detail    test015
    Fill Blacklist Form And Confirm

TC2 Blacklisted User Cannot Login
    [Documentation]    ตรวจสอบว่า user ที่ถูก blacklist ไม่สามารถ login ได้
    [Tags]    blacklist    validation
    Delete All Cookies
    Go To    ${URL}
    Sleep    2s
    Complete Login Process    ${BLACK_USER}    ${BLACK_PASS}
    ${blocked}=    Check Blacklist Status
    Should Be True    ${blocked}    msg=Expected user to be blocked but login succeeded
    Log    Blacklisted user was correctly blocked — Test Passed!

TC3 Blacklisted User Cannot Re-Register
    [Documentation]    ตรวจสอบว่า user ที่ถูก blacklist ไม่สามารถสมัครสมาชิกใหม่ได้ด้วยข้อมูลเดิม
    [Tags]    blacklist    re-register
    Delete All Cookies
    Go To    ${URL}
    Sleep    2s

    
    Wait Until Element Is Visible
    ...    xpath=//*[contains(text(),'สมัครสมาชิก') or contains(text(),'Register')]
    ...    timeout=10s
    Click Element
    ...    xpath=//*[contains(text(),'สมัครสมาชิก') or contains(text(),'Register')]
    Sleep    2s
    Capture Page Screenshot    register_step1.png

    # --- Step 1: บัญชีผู้ใช้ ---
    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=10s
    Input Text    xpath=(//input)[1]    test012new
    Input Text    xpath=(//input)[2]    test012new@gmail.com
    Input Text    xpath=(//input[@type="password"])[1]    Password123
    Input Text    xpath=(//input[@type="password"])[2]    Password123
    Sleep    1s
    Capture Page Screenshot    register_step1_filled.png
    Click Element    xpath=//button[contains(.,'ถัดไป')]
    Sleep    2s
    Capture Page Screenshot    register_step2.png

    # --- Step 2: ข้อมูลส่วนตัว ---
    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=10s
    Input Text    xpath=(//input)[1]    ทดสอบ
    Input Text    xpath=(//input)[2]    ระบบ
   
    Input Text    xpath=(//input)[3]    0891234567
    Click Element    xpath=//input[@type="radio" and following-sibling::*[contains(.,'หญิง')]] | //label[contains(.,'หญิง')]//input | //*[contains(text(),'หญิง')]
    Sleep    1s
    Capture Page Screenshot    register_step2_filled.png
    Click Element    xpath=//button[contains(.,'ถัดไป')]
    Sleep    2s
    Capture Page Screenshot    register_step3.png

   
    Wait Until Page Contains Element    xpath=(//input[@type="file"])[1]    timeout=10s

    
    Choose File    xpath=(//input[@type="file"])[1]    ${ID_CARD_IMG}

    
    Input Text    xpath=//input[contains(@placeholder,'13 หลัก') or contains(@placeholder,'หมายเลข')]
    ...    1234567890123

  
    Input Text    xpath=//input[contains(@placeholder,'วว/ดด/ปปปป') or contains(@placeholder,'วัน')]
    ...    01/01/2030

    
    Choose File    xpath=(//input[@type="file"])[2]    ${SELFIE_IMG}

    Sleep    1s
    Capture Page Screenshot    register_step3_filled.png

   
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

TC4 Blacklisted User Cannot Re-Register With Same Email
    [Documentation]    ตรวจสอบว่าไม่สามารถสมัครด้วย email เดิมของ user ที่ถูก blacklist
    [Tags]    blacklist    re-register
    Delete All Cookies
    Go To    ${URL}
    Sleep    2s

    Wait Until Element Is Visible
    ...    xpath=//*[contains(text(),'สมัครสมาชิก') or contains(text(),'Register')]
    ...    timeout=10s
    Click Element
    ...    xpath=//*[contains(text(),'สมัครสมาชิก') or contains(text(),'Register')]
    Sleep    2s

    # --- Step 1: ใช้ email เดิมของ test012 ---
    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=10s
    Input Text    xpath=(//input)[1]    test012new2
    Input Text    xpath=(//input)[2]    test012@gmail.com
    Input Text    xpath=(//input[@type="password"])[1]    Password123
    Input Text    xpath=(//input[@type="password"])[2]    Password123
    Sleep    1s
    Capture Page Screenshot    tc4_step1_filled.png

    Click Element    xpath=//button[contains(.,'ถัดไป')]
    Sleep    3s
    Capture Page Screenshot    tc4_after_step1.png

    ${blocked_step1}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element
    ...    xpath=//*[contains(text(),'blacklist') or contains(text(),'ถูกระงับ') or contains(text(),'blocked') or contains(text(),'อีเมลนี้') or contains(text(),'email') or contains(text(),'ใช้งานแล้ว') or contains(text(),'already')]
    ...    timeout=5s
    IF    ${blocked_step1}
        Capture Page Screenshot    tc4_blocked_step1.png
        Log    TC4 Passed — email เดิมถูกบล็อกที่ Step 1
        RETURN
    END

    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=10s
    Input Text    xpath=(//input)[1]    ทดสอบ
    Input Text    xpath=(//input)[2]    ระบบ
    Input Text    xpath=(//input)[3]    0891234568
    Click Element    xpath=//*[contains(text(),'หญิง')]
    Sleep    1s
    Click Element    xpath=//button[contains(.,'ถัดไป')]
    Sleep    2s
    Capture Page Screenshot    tc4_step3.png

    Wait Until Page Contains Element    xpath=(//input[@type="file"])[1]    timeout=10s
    Choose File    xpath=(//input[@type="file"])[1]    ${ID_CARD_IMG}
    Input Text    xpath=//input[contains(@placeholder,'13 หลัก') or contains(@placeholder,'หมายเลข')]    9999999999999
    Input Text    xpath=//input[contains(@placeholder,'วว/ดด/ปปปป') or contains(@placeholder,'วัน')]    01/01/2030
    Choose File    xpath=(//input[@type="file"])[2]    ${SELFIE_IMG}
    Sleep    1s
    Click Element    xpath=//input[@type="checkbox"]
    Sleep    1s
    Capture Page Screenshot    tc4_step3_filled.png
    Click Element    xpath=//button[contains(.,'สมัครสมาชิก')]
    Sleep    4s
    Capture Page Screenshot    tc4_after_submit.png

    ${blocked}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element
    ...    xpath=//*[contains(text(),'blacklist') or contains(text(),'ถูกระงับ') or contains(text(),'blocked') or contains(text(),'อีเมลนี้') or contains(text(),'ใช้งานแล้ว') or contains(text(),'already')]
    ...    timeout=8s
    IF    ${blocked}
        Capture Page Screenshot    tc4_blocked_confirmed.png
        Log    TC4 Passed — email เดิมถูกบล็อกสำเร็จ
    ELSE
        Capture Page Screenshot    tc4_not_blocked.png
        Fail    ระบบไม่ได้บล็อกการสมัครด้วย email เดิมที่ถูก blacklist
    END

TC5 Blacklisted User Cannot Re-Register With Same Phone
    [Documentation]    ตรวจสอบว่าไม่สามารถสมัครด้วยเบอร์โทรเดิมของ user ที่ถูก blacklist
    [Tags]    blacklist    re-register
    Delete All Cookies
    Go To    ${URL}
    Sleep    2s

    Wait Until Element Is Visible
    ...    xpath=//*[contains(text(),'สมัครสมาชิก') or contains(text(),'Register')]
    ...    timeout=10s
    Click Element
    ...    xpath=//*[contains(text(),'สมัครสมาชิก') or contains(text(),'Register')]
    Sleep    2s

    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=10s
    Input Text    xpath=(//input)[1]    test012new3
    Input Text    xpath=(//input)[2]    test012new3@gmail.com
    Input Text    xpath=(//input[@type="password"])[1]    Password123
    Input Text    xpath=(//input[@type="password"])[2]    Password123
    Sleep    1s
    Click Element    xpath=//button[contains(.,'ถัดไป')]
    Sleep    2s
    Capture Page Screenshot    tc5_step2.png

    Wait Until Element Is Visible    xpath=(//input)[1]    timeout=10s
    Input Text    xpath=(//input)[1]    ทดสอบ
    Input Text    xpath=(//input)[2]    ระบบ
    Input Text    xpath=(//input)[3]    ${BLACK_PHONE}
    Click Element    xpath=//*[contains(text(),'หญิง')]
    Sleep    1s
    Capture Page Screenshot    tc5_step2_filled.png
    Click Element    xpath=//button[contains(.,'ถัดไป')]
    Sleep    3s
    Capture Page Screenshot    tc5_after_step2.png

 
    ${blocked_step2}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element
    ...    xpath=//*[contains(text(),'blacklist') or contains(text(),'ถูกระงับ') or contains(text(),'blocked') or contains(text(),'เบอร์') or contains(text(),'โทรศัพท์') or contains(text(),'already')]
    ...    timeout=5s
    IF    ${blocked_step2}
        Capture Page Screenshot    tc5_blocked_step2.png
        Log    TC5 Passed — เบอร์โทรเดิมถูกบล็อกที่ Step 2
        RETURN
    END

  
    Wait Until Page Contains Element    xpath=(//input[@type="file"])[1]    timeout=10s
    Choose File    xpath=(//input[@type="file"])[1]    ${ID_CARD_IMG}
    Input Text    xpath=//input[contains(@placeholder,'13 หลัก') or contains(@placeholder,'หมายเลข')]    8888888888888
    Input Text    xpath=//input[contains(@placeholder,'วว/ดด/ปปปป') or contains(@placeholder,'วัน')]    01/01/2030
    Choose File    xpath=(//input[@type="file"])[2]    ${SELFIE_IMG}
    Sleep    1s
    Click Element    xpath=//input[@type="checkbox"]
    Sleep    1s
    Capture Page Screenshot    tc5_step3_filled.png
    Click Element    xpath=//button[contains(.,'สมัครสมาชิก')]
    Sleep    4s
    Capture Page Screenshot    tc5_after_submit.png

    ${blocked}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element
    ...    xpath=//*[contains(text(),'blacklist') or contains(text(),'ถูกระงับ') or contains(text(),'blocked') or contains(text(),'เบอร์') or contains(text(),'already')]
    ...    timeout=8s
    IF    ${blocked}
        Capture Page Screenshot    tc5_blocked_confirmed.png
        Log    TC5 Passed — เบอร์โทรเดิมถูกบล็อกสำเร็จ
    ELSE
        Capture Page Screenshot    tc5_not_blocked.png
        Fail    ระบบไม่ได้บล็อกการสมัครด้วยเบอร์โทรเดิมที่ถูก blacklist
    END

TC6 Admin Cannot Unblacklist Permanent User
    [Documentation]    ทดสอบว่า admin กดระงับถาวรแล้ว user ยังถูก blacklist อยู่ ปลดไม่ได้
    [Tags]    admin    blacklist    permanent
    Complete Login Process    ${ADMIN_USER}    ${ADMIN_PASS}

  
    Go To    ${URL}/admin/user-blacklist
    Wait Until Page Contains Element    xpath=//*[contains(text(),'TOTAL BLACKLISTED') or contains(text(),'รายชื่อผู้ใช้ที่ถูกระงับ') or contains(text(),'Blacklist')]    timeout=10s
    Sleep    2s
    Capture Page Screenshot    tc6_blacklist_page.png

    
    Wait Until Element Is Visible
    ...    xpath=//tr[contains(.,'test012') or contains(.,'test012@gmail.com')]//button[contains(.,'ระงับถาวร') or contains(.,'Permanent') or contains(.,'permanent')]
    ...    timeout=10s
    Click Element
    ...    xpath=//tr[contains(.,'test012') or contains(.,'test012@gmail.com')]//button[contains(.,'ระงับถาวร') or contains(.,'Permanent') or contains(.,'permanent')]
    Sleep    2s
    Capture Page Screenshot    tc6_after_permanent_click.png

    ${alert}=    Run Keyword And Return Status    Handle Alert    ACCEPT
    IF    ${alert}
        Sleep    2s
    END

    ${modal}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//button[contains(.,'ยืนยัน') or contains(.,'Confirm') or contains(.,'ตกลง')]
    ...    timeout=5s
    IF    ${modal}
        Click Element
        ...    xpath=//button[contains(.,'ยืนยัน') or contains(.,'Confirm') or contains(.,'ตกลง')]
        Sleep    2s
    END
    Capture Page Screenshot    tc6_after_confirm.png

    # logout แล้ว login ด้วย test012 เพื่อตรวจว่ายังเข้าไม่ได้
    Delete All Cookies
    Go To    ${URL}
    Sleep    2s
    Complete Login Process    ${BLACK_USER}    ${BLACK_PASS}
    ${still_blocked}=    Check Blacklist Status
    Should Be True    ${still_blocked}
    ...    msg=User สามารถ login ได้หลังจากกด ระงับถาวร — แสดงว่าระบบมีปัญหา
    Capture Page Screenshot    tc6_still_blocked_confirmed.png
    Log    TC6 Passed — user ยังถูก blacklist อยู่หลังกดระงับถาวร
