Web App OS
=============

♦Introduction
---------------

The most advanced how to develop web application in the world. 

Without programing using code, such as PHP, Java, Perl, 

You can Cook a Full Customized Relational Data Bind Web Application.

♦Setup
-------
####Procedure of development environment construction(for windows) beta_0.1.0

###Outline
This document explains the procedure to construct of environment for making a website with “Web App OS-WAO-“.

###Revision History
2014/03/25  new create

###Running Environment
WAO needs the following a software to run on at least.  
・JDK7  
・Apache Ant1.9.2  
・Tomcat 7  
・PostgreSQL9.2

1. Download a wao_all_beta_0_1_X.zip from GitHub

2. Extract to htdocs in Apache and change the folder name to the context name of the site

3. Construct a database  
 3-1. Create a ‘user’ and ‘database’ named same as context name  

 3-2. Create a system table of WAO on the database that you created at 3-1.  
 　　At this time, ‘OWNER’ should be same as ‘user’ which you create at 3-1.  
 　　[Arbitrarily folder]\site\db\sql\webappos_ddl.sql

4. Alter the setting folder  
 4-1. Set WAO  
　　[Arbitrarily folder]\site\conf\wao_config.ini
 　　[WebAppOS Settings]  
 　　enable_SSI: If you implement HTML file with Apache using SSI, you should turn ‘ON’.  
 　　In other case, turn ‘OFF’.  
 　　webapps_path = the place of WAO’s system file　outside of web  
 　　[Environment Settings]  
 　　ant_home = the directory in which ‘Ant’ was installed.  
 　　tomcat_home = the directory in which ‘Tomcat’ was installed.  

 4-2. Change the setting for the website  
 　　[Arbitrarily folder]\site\conf\default\site_config.ini  
 　　[App Base Settings]  
 　　context.mode: If you include the context name in URL of your website, should be ‘true’.  
 　　In other case, should be ‘false’.  
 　　root.package: AS a rule of naming Java package*  
 　　*Start from it reversed the order of a name of top level domain and sub main list.  
 　　[DB Settings]  
 　　password = the password of database created at 4.

5. Create and place files of HTML,CSS and JS  
[An arbitrarily folder]\site\html  
[An arbitrarily folder]\site\web  

6. Bury attribute in HTML  
For details about attribute, see another sheet.

7. Execute a batch processing of website construction  
[An arbitrarily folder]\wao\bin\deploy.bat

8. Access from a browser  
http://localhost:8080/'context name’/

♦Minor update
-------------------------------------------------------------------------
1. Download wao_all_binary_0_1_X.zip from sourceforge  
https://sourceforge.jp/projects/web-app-os/releases/

2. Place a library
[An arbitrarily folder]\wao\lib  
*delete an old ’jar’ file.

3. Alter setting file of WAO  
[An arbitrarily folder]\site\conf\wao_config.ini  
wao_verion: Alter to the version of WAO you acquired.
   

###Folder construction
    [context name]
     └site
       ├conf    place setting files in
       │ ├default	 place setting files for development environment in
       │ ├product	 place setting files for production environment in
       │ └stage	 place setting files for test environment in
       ├db
       │ ├mapper	If you create sql by your own, place Mapper files that describe sql with MyBatis in
       │ └sql		place sql files in
       ├html		place html include attribute created by yourself in*
       │			*place index.html necessarily in
       ├include	If you use SSI, place include files in
       ├mail		place mail template_files in
       └web　 *The folder construction is flexible here.
          ├css		place stylesheets in
          ├img		place image resource in
          └js 		place javascript file in
          
◆FunctionList
-------------
####Please install the pdf.

*English:[FunctionList.pdf](https://github.com/hws-aoyagi/web-app-os-src/blob/master/documents/Englilsh/FunctionList.pdf?raw=true)*  
*Japanese:[機能一覧.pdf](https://github.com/hws-aoyagi/web-app-os-src/blob/master/documents/%E6%97%A5%E6%9C%AC%E8%AA%9E/%E6%A9%9F%E8%83%BD%E4%B8%80%E8%A6%A7.pdf?raw=true)*

◆Attribute Spec
---------------
####Please install the pdf.

*English:[WebAppOS__Attribute_Spec_β.pdf](https://github.com/hws-aoyagi/web-app-os-src/blob/master/documents/Englilsh/WebAppOS_Attribute_Spec_%CE%B2.pdf?raw=true)*  
*Japanese:[WebAppOS_API仕様書β.pdf](https://github.com/hws-aoyagi/web-app-os-src/blob/master/documents/%E6%97%A5%E6%9C%AC%E8%AA%9E/WebAppOS_API%E4%BB%95%E6%A7%98%E6%9B%B8_%CE%B2.pdf?raw=true)*
emphasized text

◆Source Repository
---------------
https://github.com/web-app-os/web-app-os-src