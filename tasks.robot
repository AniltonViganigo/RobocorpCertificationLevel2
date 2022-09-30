*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images

Library             RPA.Browser.Selenium    auto_close={False}
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.HTTP
Library             RPA.FileSystem
Library             RPA.PDF
Library             RPA.Archive


*** Variables ***
${PDF_FolderPath}=          ${CURDIR}${/}ROBOT_PDF/
${CSV_FolderPath}=          ${CURDIR}${/}ROBOT_CSV
${SCREEN_FolderPath}=       ${CURDIR}${/}ROBOT_SCREENSHOTS
${URL_CSV}=                 https://robotsparebinindustries.com/orders.csv
${URL_WEBSITE}=             https://robotsparebinindustries.com/#/robot-order

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open The Robot Order Website
    ${orders}=    Read CSV File
    FOR    ${row}    IN    @{orders}
        Log    ${row}[Head]
        Fill The Form    ${row}[Order number]    ${row}[Body]    ${row}[Head]    ${row}[Legs]    ${row}[Address]                  
    END
    ZIP PDF Folder

*** Keywords ***
Open The Robot Order Website
    Open Available Browser    ${URL_WEBSITE}
    Maximize Browser Window
    Click On Message
    
Download CSV File
    Create Directory    ${CSV_FolderPath}
    Download    ${URL_CSV}    ${CSV_FolderPath}${/}Arquivos.csv    

Read CSV File
    ${csv_table}=    Read table from CSV    ${CSV_FolderPath}${/}Arquivos.csv    
    RETURN    ${csv_table}

Fill The Form
    [Arguments]    ${OrderNumber}    ${Head}    ${Body}    ${Legs}    ${Address}
    Select From List By Value    id:head    ${Head}
    Select Radio Button    body    ${Body}
    Input Text    class:form-control    ${Legs}
    Input Text    id:address    ${Address}
    Click Button    id:preview
    Wait Until Keyword Succeeds    6x    2 sec    Click Order and Check Recibo
    Take a Screeshot of The Robot
    PDF File    ${OrderNumber}
    Click Button    id:order-another

    ${Message}=    Does Page Contain Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    IF    ${Message}    Click On Message

Take a Screeshot of The Robot
    Create Directory    ${SCREEN_FolderPath}
    Wait Until Element Is Visible    id:robot-preview-image
    Capture Element Screenshot    id:robot-preview-image    filename=${SCREEN_FolderPath}${/}Bot_Picture.png
    
Click Order and Check Recibo
    Click Button    id:order
    Click Element    id:receipt

PDF File
    [Arguments]    ${OrderNumber}
    Create Directory    ${PDF_FolderPath}
    ${recibo}=    Get Element Attribute    id:receipt    outerHTML
    ${filename}=    Set Variable    ${PDF_FolderPath}${OrderNumber}.pdf
    Html To Pdf    ${recibo}    ${filename}
    Open Pdf    ${filename}
    Add Watermark Image To Pdf    ${SCREEN_FolderPath}${/}Bot_Picture.png    ${filename}
    Close Pdf

Click On Message
    Click Element    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

ZIP PDF Folder
    ${ZIP_FilePath}=    Set Variable    ${PDF_FolderPath}/PDF.zip
    Archive Folder With Zip    ${PDF_FolderPath}    ${ZIP_FilePath}
        