# PWM deployment

## Overview

The purpose of this deployment is to instantiate the PWM application as a cf app. 
PWM is an open source password self service application for LDAP directories.
PWM aims to create CAP users in the internal Open LDAP platform. 

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | Cf app deployment |
| Depends on | [PWM project](https://github.com/pwm-project/pwm) |
| Uses of | [PWM artifacts](https://www.pwm-project.org/artifacts/pwm/) |
| Vars files | Yes |
| Ops files | NA |

## Architecture

The application is written in Java
PWM instanciation for CAP depends on : 
* An LDAP server
* A mySQL database
* An email server

## New PWM version setup

This phase consists in selecting a new version from the PWM artifacts repository.


* The super user password is stored in the secrets repository (file ConfigurationManager_Password.txt) 

* Enable configuration mode in PwmConfiguration.xml 
    <property key="configIsEditable" modifyTime="2017-08-08T13:45:16Z">true</property>

* Click button "Configuration Editor" in order to check and amend missing back-end parameters (sign in with password stored in the file ConfigurationManager_Password.txt if needed) : 
	-LDAP/LDAP Directories/default/Connection
		/LDAP URLs
		/LDAP Proxy User (available in shared/secrets.yml)
		/LDAP Proxy Password (available in shared/secrets.yml)
	-Settings/Database/Connection
		/Database Connection String (binding information)
		/Database User Name (binding information)
		/Database Password  (binding information)
	-Settings/Email/Email Servers/default
		/SMTP Server Address (available in shared/secrets.yml)
		/SMTP Server Port (available in shared/secrets.yml)
		/SMTP Server User Name  (available in shared/secrets.yml)
		/SMTP Server Password  (available in shared/secrets.yml)
		
* Save new configuration by clicking the button in the icon disk (upper right corner) (sign in with password stored in the file ConfigurationManager_Password.txt if needed) 

* Click button "Configuration Manager" in order to export the new configuration  (sign in with password stored in the file ConfigurationManager_Password.txt if needed) 

* Update the PwmConfiguration.xml file with the new one exported previously (in secrets repository)

* Disable configuration mode in PwmConfiguration.xml 
    <property key="configIsEditable" modifyTime="2017-08-08T13:45:16Z">false</property>

## Tips

N/A

## See also

* [PWM project](https://github.com/pwm-project/pwm)
* [PWM artifacts](https://www.pwm-project.org/artifacts/pwm/)

## To do

N/A