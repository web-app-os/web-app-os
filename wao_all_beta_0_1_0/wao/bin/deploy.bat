@echo off

rem
rem generate and deploy web application
rem

setlocal

rem set const
set WAO_CONF_NAME=wao_config.ini
set SITE_CONF_NAME=site_config.ini
set BLANK_PRJ=BlankProject
set DAT_FILE_NAME=webappos.dat

rem set build mode
set BUILD_MODE=%~1
if not DEFINED BUILD_MODE (
  set BUILD_MODE=diff
)

rem set build env
set TARGET_ENV=%~2
if not DEFINED TARGET_ENV (
  set TARGET_ENV=default
)

rem set context name
cd /d %~dp0
cd /d ..\..
for /f "delims=" %%a in ("%cd%") do set CONTEXT_NAME=%%~na

echo ================================================================================
echo context:%CONTEXT_NAME%
echo contextPath:"%cd%"
if "%BUILD_MODE%" == "full" (
  echo mode:full build
) else (
  echo mode:diff build
)
echo env:%TARGET_ENV%
echo ================================================================================

rem set path
set SITE_PATH=%cd%\site\
set CONF_PATH=%SITE_PATH%conf\
set WAO_PATH=%cd%\wao\
set PRJ_PATH=%WAO_PATH%project\%CONTEXT_NAME%
set GEN_PATH=%WAO_PATH%gen\
set RELEASE_PATH=%cd%\release

echo --- load wao_config.ini ---
if not exist "%CONF_PATH%%WAO_CONF_NAME%" (
  echo %WAO_CONF_NAME% does not exist. abnormal end.
  pause
  goto :EOF
) else (
  for /f "tokens=1,* delims== usebackq" %%a in ("%CONF_PATH%%WAO_CONF_NAME%") do (
    set %%a=%%b
  )
)

echo --- load site_config.ini ---
if not exist "%CONF_PATH%%TARGET_ENV%\%SITE_CONF_NAME%" (
  echo %SITE_CONF_NAME% does not exist. abnormal end.
  pause
  goto :EOF
) else (
  for /f "tokens=1,* delims== usebackq" %%a in ("%CONF_PATH%%TARGET_ENV%\%SITE_CONF_NAME%") do (
    set %%a=%%b
  )
)

echo --- set war name  ---
SET WAR_NAME=%CONTEXT_NAME%
if "%context_mode%" == "false" (
  SET WAR_NAME=ROOT
)

echo --- delete in directory ---
rmdir /S /Q "%GEN_PATH%in\html"
rmdir /S /Q "%GEN_PATH%in\web"
mkdir "%GEN_PATH%in\html"
mkdir "%GEN_PATH%in\web"

set WGET_URL=http://localhost/%CONTEXT_NAME%/site/html
if "%enable_SSI%" == "on" (
  echo --- exec wget ---
  rem TODO:diffの場合、前回実行日時以降に変更のあったファイルのみをwgetする
  rmdir /S /Q "%GEN_PATH%in\wget"
  wget -x -r %WGET_URL%/index.html  > nul 2>&1 -P "%GEN_PATH%in\wget"

  echo --- copy html and web to in directory ---
  xcopy "%GEN_PATH%in\wget\localhost\%CONTEXT_NAME%\site\html" "%GEN_PATH%in\html" /D /E /I /Q /Y
  xcopy "%SITE_PATH%web" "%GEN_PATH%in\web" /D /E /I /Q /Y
  xcopy "%GEN_PATH%in\wget\localhost\%CONTEXT_NAME%\site\web" "%GEN_PATH%in\web" /D /E /I /Q /Y
) else (
  echo --- copy html and web to in directory ---
  xcopy "%SITE_PATH%html" "%GEN_PATH%in\html" /D /E /I /Q /Y
  xcopy "%SITE_PATH%web" "%GEN_PATH%in\web" /D /E /I /Q /Y
)

echo --- copy env properties to in directory ---
xcopy "%CONF_PATH%%TARGET_ENV%\*.properties" "%GEN_PATH%in\properties" /D /E /I /Q /Y

echo --- copy mapper files to in directory ---
xcopy "%SITE_PATH%db\mapper" "%GEN_PATH%in\mapper" /D /E /I /Q /Y

echo --- exec generator ---
set CONNECTION_URL=jdbc:postgresql://%host%:%port%/
set GEN_JAR="%WAO_PATH%lib\webappos-generator_%wao_verion%.jar"
java -jar %GEN_JAR% %CONTEXT_NAME% %password%

echo --- create web project ---
rmdir /S /Q "%PRJ_PATH%"
xcopy "%WAO_PATH%project\%BLANK_PRJ%" "%PRJ_PATH%" /D /E /I /Q /Y
echo --- copy properties to web project directory ---
xcopy "%GEN_PATH%in\properties\*.properties" "%PRJ_PATH%\properties" /D /E /I /Q /Y
xcopy "%GEN_PATH%out\properties\*.*" "%PRJ_PATH%\properties" /D /E /I /Q /Y
echo --- copy src to web project directory ---
xcopy "%GEN_PATH%out\src\*.*" "%PRJ_PATH%\src" /D /E /I /Q /Y
echo --- copy mapper to web project directory ---
set MAPPER_PATH=\src\%root_package:.=\%\mapper
xcopy "%GEN_PATH%in\mapper" "%PRJ_PATH%\%MAPPER_PATH%" /D /E /I /Q /Y
echo --- copy web to web project directory ---
xcopy "%GEN_PATH%in\web" "%PRJ_PATH%\web" /D /E /I /Q /Y
xcopy "%GEN_PATH%out\web\*.*" "%PRJ_PATH%\web" /D /E /I /Q /Y
echo --- copy controller lib to web project directory ---
xcopy "%WAO_PATH%lib\webappos-controller_%wao_verion%.jar" "%PRJ_PATH%\web\WEB-INF\lib" /D /E /I /Q /Y

echo --- exec ant ---
call %ant_home%\bin\ant -f "%PRJ_PATH%\build.xml"

echo --- copy dat to dist directory ---
xcopy "%GEN_PATH%out\dat\%DAT_FILE_NAME%" "%RELEASE_PATH%" /D /E /I /Q /Y
echo --- copy war to dist directory ---
move "%PRJ_PATH%\dist\%CONTEXT_NAME%.war" "%PRJ_PATH%\dist\%WAR_NAME%.war"
xcopy "%PRJ_PATH%\dist\%WAR_NAME%.war" "%RELEASE_PATH%" /D /E /I /Q /Y

echo --- tomcat shutdown ---
set CATALINA_HOME=%tomcat_home%
echo CATALINA_HOME:%CATALINA_HOME%
call "%tomcat_home%\bin\shutdown.bat"

echo --- deploy war ---
rmdir /S /Q "%tomcat_home%\work"
rmdir /S /Q "%tomcat_home%\webapps\%WAR_NAME%"
move "%tomcat_home%\webapps\%WAR_NAME%.war" "%RELEASE_PATH%\%WAR_NAME%_bk.war"
xcopy "%RELEASE_PATH%\%WAR_NAME%.war" "%tomcat_home%\webapps" /D /E /I /Q /Y

echo --- copy dat file ---
rmdir /S /Q "%webapps_path%\%CONTEXT_NAME%\webapps\dat"
mkdir "%webapps_path%\%CONTEXT_NAME%\webapps\dat"
xcopy "%RELEASE_PATH%\%DAT_FILE_NAME%" "%webapps_path%\%CONTEXT_NAME%\webapps\dat" /D /E /I /Q /Y

echo --- copy mail template file ---
rmdir /S /Q "%webapps_path%\%CONTEXT_NAME%\webapps\mail"
mkdir "%webapps_path%\%CONTEXT_NAME%\webapps\mail"
xcopy "%SITE_PATH%\mail" "%webapps_path%\%CONTEXT_NAME%\webapps\mail" /D /E /I /Q /Y

echo --- tomcat startup ---
call "%tomcat_home%\bin\startup.bat"

pause
endlocal
