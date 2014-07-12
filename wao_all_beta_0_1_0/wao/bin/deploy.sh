#!/bin/sh
#
# generate and deploy web application
#

# set const
WAO_CONF_NAME=wao_config.ini
SITE_CONF_NAME=site_config.ini
BLANK_PRJ=BlankProject
DAT_FILE_NAME=webappos.dat

# set build mode
if [ -z "$1" ]
then
  BUILD_MODE="diff"
else
  BUILD_MODE=$1
fi

# set build env
if [ -z "$2" ]
then
  TARGET_ENV="default"
else
  TARGET_ENV=$2
fi

#set context name

BASEDIR=$(dirname $0)

cd $BASEDIR
cd ../..

CURRENT_DIR="$( pwd )"
CONTEXT_NAME="$(basename "$CURRENT_DIR")"

echo ================================================================================
echo context:$CONTEXT_NAME
echo contextPath:$CURRENT_DIR
if [ $BUILD_MODE = "full" ]
then
  echo mode:full build
else
  echo mode:diff build
fi
echo env:$TARGET_ENV

echo ================================================================================

#set path
SITE_PATH=${CURRENT_DIR}/site/
CONF_PATH=${SITE_PATH}conf/
WAO_PATH=${CURRENT_DIR}/wao/
PRJ_PATH=${WAO_PATH}project/${CONTEXT_NAME}
GEN_PATH=${WAO_PATH}gen/
RELEASE_PATH=${CURRENT_DIR}/release

echo --- load wao_config.ini ---
if [ -f "${CONF_PATH}${WAO_CONF_NAME}" ]
then
  while IFS=/= read variable value
  do
    [ -z "$value" ] && continue
    export $variable=$value

  done <"${CONF_PATH}${WAO_CONF_NAME}"
else
  read -sn 1 -p "${WAO_CONF_NAME} does not exist. abnormal end."
  exit
fi

echo --- load site_config.ini ---
if [ -f "${CONF_PATH}${TARGET_ENV}/${SITE_CONF_NAME}" ]
then
  while IFS=/= read variable value
  do
    [ -z "$value" ] && continue
    #linux shell not accept . character in variable name. convert a.b -> a_b
    variable=${variable//./_}
    export $variable=$value
  done <"${CONF_PATH}${TARGET_ENV}/${SITE_CONF_NAME}"
else
  read -sn 1 -p "${SITE_CONF_NAME} does not exist. abnormal end."
  exit
fi

echo --- set war name  ---
WAR_NAME=${CONTEXT_NAME}
if [ "$context_mode" = "false" ]; then
  WAR_NAME=ROOT
fi

echo --- delete in directory ---
rm -rf "${GEN_PATH}in/html"
rm -rf "${GEN_PATH}in/web"
rm -rf "${GEN_PATH}in/properties"
mkdir -p "${GEN_PATH}in/properties"

WGET_URL=http://localhost/${CONTEXT_NAME}/site/html/index.html
if [ "${enable_SSI}" = "on" ]; then
  echo --- exec wget %WGET_URL% ---
  rm -rf "${GEN_PATH}in/wget"
  wget -x -r ${WGET_URL} > /dev/null 2>&1 -P "${GEN_PATH}in/wget"
  echo --- copy html and web to in directory ---
  cp -aR "${GEN_PATH}in/wget/localhost/${CONTEXT_NAME}/site/html" "${GEN_PATH}in/html"
  cp -aR "${SITE_PATH}web" "${GEN_PATH}in/web"
  cp -aR "${GEN_PATH}in/wget/localhost/${CONTEXT_NAME}/site/web" "${GEN_PATH}in/web"
else
  echo --- copy html and web to in directory ---
  cp -aR "${SITE_PATH}html" "${GEN_PATH}in/html"
  cp -aR "${SITE_PATH}web" "${GEN_PATH}in/web"
fi

echo --- copy env properties to in directory ---
cp -aR ${CONF_PATH}${TARGET_ENV}/*.properties "${GEN_PATH}in/properties/"

echo --- copy mapper files to in directory ---
cp -aR "${SITE_PATH}db/mapper" "${GEN_PATH}in/mapper/"

echo --- exec generator ---
CONNECTION_URL=jdbc:postgresql://${host}:${port}/
export GEN_PATH
export CONNECTION_URL
GEN_JAR="${WAO_PATH}lib/webappos-generator_${wao_verion}.jar"
java -jar ${GEN_JAR} ${CONTEXT_NAME} ${password}

echo --- create web project ---
rm -rf "${PRJ_PATH}"
cp -aR "${WAO_PATH}project/${BLANK_PRJ}" "${PRJ_PATH}"
echo --- copy properties to web project directory ---
cp -aR ${GEN_PATH}in/properties/*.properties "${PRJ_PATH}/properties"
cp -aR ${GEN_PATH}out/properties/* "${PRJ_PATH}/properties"
echo --- copy src to web project directory ---
cp -aR ${GEN_PATH}out/src/* "${PRJ_PATH}/src"
echo --- copy mapper to web project directory ---
MAPPER_PATH=src/${root_package//./\/}/mapper

cp -aR "${GEN_PATH}in/mapper" "${PRJ_PATH}/${MAPPER_PATH}"
echo --- copy web to web project directory ---
cp -aR "${GEN_PATH}in/web" "${PRJ_PATH}"
cp -aR ${GEN_PATH}out/web/* "${PRJ_PATH}/web"
echo --- copy controller lib to web project directory ---
cp -aR "${WAO_PATH}lib/webappos-controller_${wao_verion}.jar" "${PRJ_PATH}/web/WEB-INF/lib"

echo --- exec ant ---
export CONTEXT_NAME
${ant_home}/bin/ant -f "${PRJ_PATH}/build.xml"

echo $PRJ_PATH

echo --- copy dat to dist directory ---
cp -aR "${GEN_PATH}out/dat/${DAT_FILE_NAME}" "${RELEASE_PATH}"
echo --- copy war to dist directory ---
mv "${PRJ_PATH}/dist/${CONTEXT_NAME}.war" "${PRJ_PATH}/dist/${WAR_NAME}.war"
cp -aR "${PRJ_PATH}/dist/${WAR_NAME}.war" "${RELEASE_PATH}"

echo --- tomcat shutdown ---
CATALINA_HOME=${tomcat_home}
echo CATALINA_HOME:${CATALINA_HOME}
${tomcat_home}/bin/shutdown.sh

echo --- deploy war ---
rm -rf "${tomcat_home}/work"
rm -rf "${tomcat_home}/webapps/${WAR_NAME}"
mv "${tomcat_home}/webapps/${WAR_NAME}.war" "${RELEASE_PATH}/${WAR_NAME}_bk.war"
cp -aR "${RELEASE_PATH}/${WAR_NAME}.war" "${tomcat_home}/webapps"

echo --- copy dat file ---
rm -rf "${webapps_path}/${CONTEXT_NAME}/webapps/dat"
mkdir -p "${webapps_path}/${CONTEXT_NAME}/webapps/dat"
cp -aR "${RELEASE_PATH}/${DAT_FILE_NAME}" "${webapps_path}/${CONTEXT_NAME}/webapps/dat"

echo --- copy mail template file ---
rm -rf "${webapps_path}/${CONTEXT_NAME}/webapps/mail"
mkdir -p "${webapps_path}/${CONTEXT_NAME}/webapps/mail"
cp -aR "${SITE_PATH}/mail" "${webapps_path}/${CONTEXT_NAME}/webapps/mail"

echo --- tomcat startup ---
${tomcat_home}/bin/startup.sh

read -sn 1
