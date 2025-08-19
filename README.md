<h5><b><i>Note to Reader: Where permissible - the source code will readily be provided. There are cases where IP | Copyright factors apply. In those cases the source code cannot be published without the StakeHolders consent. Thank you for your understanding.</b></i></h5>
<br/>

<h1>Oracle21cClient-Windows_AutoDeploy</h1>
<br/>


<h2>Description</h2>
<b>Oracle21c Client (Windows) Install and UnInstall (Rollback) PowerShell scripts for 32 bit / 64 bit Architecture. Scripts are based on the below points:</b>
<br/>
<br/>

  - Oracle21c is the incoming Client Install: Oracle12c is the existing default client.
  - Uninstall scripts to be run AFTER install scripts should ROLLBACK be required. 
  - Within POWERSHELL scripts:
    - Variable <APPROPRIATE_PATH> is to be replaced with your desired path.
    - Installation / log / source files are generic templates, however C and D drives are default base points. Please tailor to your environment.
    - Oracle 21c Silent install performs ADMIN installation. If another installation type is desired - please tailor to your environment.
  - For the Client -  Oracle 21C Windows Client [64 bit / 32 bit] installation is used for the silent install. 
    - Please see at: https://www.oracle.com/database/technologies/oracle21c-windows-downloads.html
  - Default 21c install response file provided [21c install response_file](https://github.com/psZh3ePNj0/Oracle21cClient-Windows_AutoDeploy/blob/main/install_oracle_client_administrator_21c.rsp)
    - PLEASE tailor response file according to your requirements. 
    - NOTE: after making your changes - response file needs to be placed in the $ORACLE_HOME/client directory. Rename response file to meet your requirements (ex oracle21_installclient-cdrive.rsp)
  - Powershell Uninstall script should dynamically generate uninstall response file (based on ADMIN installation). However, a default uninstall response file is provided [uninstall response_file](https://github.com/psZh3ePNj0/Oracle21cClient-Windows_AutoDeploy/blob/main/deinstall_OraClientHome.rsp). 
    - PLEASE tailor uninstall response file according to your requirements. 
    - NOTE: after making your changes - uninstall response file needs to be placed in the $ORACLE_HOME/client directory. Rename uninstall response file to meet your requirements (ex oracle21_uninstallclient-cdrive.rsp)

<br/>


<h2>Languages, Utilities and Dependencies </h2>

- <b>Windows Powershell</b>
- <b>NotePad++ / Visual Studio Code IDE </b> 
<br/>


<h2>Environments Tested and Used </h2>

- <b>Windows 10 [32 bit / 64 bit] | Windows 2012 Server [32 bit / 64 bit]</b>
- <b>Oracle Database Client 21c Enterprise Edition [Windows][32 bit / 64 bit] </b>
<br/>



<h2>Additional Reference Sources </h2>

- <b>https://silentinstallhq.com/oracle-database-21c-client-silent-install-how-to-guide/</b>
- <b>https://docs.oracle.com/cd/E83817_01/UDMIG/silent-installation.htm</b>
<br/>
