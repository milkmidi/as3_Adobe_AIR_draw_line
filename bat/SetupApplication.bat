:user_configuration


:: Your application ID (must match <id> of Application descriptor)
set APP_ID=com.milkmidi.line

:: Output packages
set DIST_PATH=dist
set DIST_NAME=milkmidi_line

:: Debugging using a custom IP
set DEBUG_IP=

set AND_CERT_NAME="milkmidi"
set AND_CERT_PASS=blue0909
set AND_CERT_FILE=D:\48_Android_AIR\milkmidi.p12
set AND_ICONS=icons/android

set AND_SIGNING_OPTIONS=-storetype pkcs12 -keystore "%AND_CERT_FILE%" -storepass %AND_CERT_PASS%

:: iOS packaging
set IOS_DIST_CERT_FILE=E:\BackUpmedialandWork\[Medialand]\p12\tw.medialand.p12
set IOS_DEV_CERT_FILE=E:\BackUpmedialandWork\[Medialand]\p12\tw.medialand.p12
set IOS_DEV_CERT_PASS=13128233
set IOS_PROVISION=E:\BackUpmedialandWork\[Medialand]\p12\ML_Flash_Test.mobileprovision
set IOS_ICONS=icons/ios

set IOS_DEV_SIGNING_OPTIONS=-storetype pkcs12 -keystore "%IOS_DEV_CERT_FILE%" -storepass %IOS_DEV_CERT_PASS% -provisioning-profile %IOS_PROVISION%
set IOS_DIST_SIGNING_OPTIONS=-storetype pkcs12 -keystore "%IOS_DIST_CERT_FILE%" -provisioning-profile %IOS_PROVISION%

:: Application descriptor
set APP_XML=application.xml

:: Files to package
set APP_DIR=bin
set FILE_OR_DIR=-C %APP_DIR% .



:: About AIR application packaging
:: http://livedocs.adobe.com/flex/3/html/help.html?content=CommandLineTools_5.html#1035959
:: http://livedocs.adobe.com/flex/3/html/distributing_apps_4.html#1037515

:: NOTICE: all paths are relative to project root

:: Android packaging


:validation
%SystemRoot%\System32\find /C "<id>%APP_ID%</id>" "%APP_XML%" > NUL
if errorlevel 1 goto badid
goto end

:badid
echo.
echo ERROR: 
echo   Application ID in 'bat\SetupApplication.bat' (APP_ID) 
echo   does NOT match Application descriptor '%APP_XML%' (id)
echo.

:end