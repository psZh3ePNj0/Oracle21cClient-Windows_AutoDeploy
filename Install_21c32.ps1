########################################################################################################
#	
#	FileName:		Install_21c32.ps1
#	Author:			Christophe Cartwright, Oracle DBA
#	Date:			
#	Version:		1.0
#	Description:	Shell Script Vets for Oracle_Homes (from inventory.xmls)
# 					Depending on checks, Oracle 21c [32] will be Dynamically installed  in Silent Mode
#
#	Acknowledgements: (Jason Bergner) https://silentinstallhq.com/oracle-database-19c-client-install-and-uninstall-powershell/
#						
#
#	Revision History:
#	Revisionist:
#
########################################################################################################





try{

    Start-transcript -Path "C:\Oracle21C32_Install.txt"

	$Host_Name = hostname
		
	$d-drive_verify = Test-Path -Path "D:\" 

	
	$inventoryxml_32 = Test-Path -Path "C:\Program Files (x86)\Oracle\Inventory\ContentsXML\inventory.xml" -PathType Leaf
	$inventory_logs = Test-Path -Path "C:\Program Files (x86)\Oracle\Inventory\logs\*"  -PathType Leaf
	

	
	if ($inventoryxml_32)
	{
	
		$RawXMLFile = get-childitem 'C:\Program Files (x86)\Oracle\Inventory\ContentsXML' -file -include inventory.xml -Recurse

		foreach ($file in $RawXMLFile)
		{

            $xmlf = [xml](get-content -path $file.FullName)

			$HomeLocations = $xmlf.INVENTORY.HOME_LIST.HOME
			$HomeLocationsCount = $xmlf.INVENTORY.HOME_LIST.HOME.NAME.count
			$HomeLocationsCurrent = 1


			# Oracle12Home Variable to Extract Already configured 12c TNSNames. This will be copied to the OH 21c and used.
			# This is done as the different environments are specifically configured and a central TNS cannot be used.
			# Key factor to this working is that 12c is deinstalled AFTER 21c is installed.
			
			$12cHloc = $null
			
			foreach ($location in $HomeLocations)
			{
				$Hname = $location.NAME
				$Hloc = $location.LOC
				$Hidx = $location.IDX
						
				write-host 
				
				
				
					if ($Hname -like "OraClient21Home*")	
					{
						write-host ====================================================================================================
						write-host
						write-host "Oracle21c 32bit Client already installed."
						write-host
						write-host "Oracle name is: " $Hname
						write-host "Oracle home is: " $Hloc
						write-host
						write-host "Please review contents of ORACLE_HOME $Hloc for appropriate action."
						write-host "If required, contact your Oracle DBAs for guidance."
						write-host "Exiting Oracle21c 32bit Client Install."
						write-host
						write-host ====================================================================================================
						write-host


						Stop-transcript
						C:
						Copy-Item -Path "C:\Oracle21C32_Install.txt" "<APPROPRIATE_PATH>\$Host_Name"
						Remove-Item -Path "C:\Oracle21C32_Install.txt" -Recurse -Force -Confirm:$false
					
						exit 0
					}
			
			
					elseif ( ($Hname -notlike "OraClient21Home*") -and ($HomeLocationsCurrent -ne $HomeLocationsCount))
					{
						#Set $12cHloc for the 12c Tnsnames location
						if ($Hname -eq "OraClient12Home1"){$12cHloc = $Hloc}
						
						write-host ====================================================================================================
						write-host
						write-host "Different Oracle Client installed."
						write-host
						write-host "Oracle name is: " $Hname
						write-host "Oracle home is: " $Hloc
						write-host
						write-host "Please review contents of ORACLE_HOME $Hloc for appropriate action."
						write-host "If required, contact your Oracle DBAs for guidance."
						write-host "Continuing search for Oracle21c 64bit Client."
						write-host
						write-host ====================================================================================================
						write-host
				
					}
			

					elseif ( ($Hname -notlike "OraClient21Home*") -and ($HomeLocationsCurrent -eq $HomeLocationsCount))
					{
						
						#Set $12cHloc for the 12c Tnsnames location
						if ($Hname -eq "OraClient12Home1"){$12cHloc = $Hloc}
						
						
						write-host ====================================================================================================
						write-host
						write-host "Oracle21c 32bit Client not installed. Proceeding to install Oracle21c 32bit Client. "
						write-host
						write-host ====================================================================================================
						write-host
							

						
						if ($d-drive_verify)
						{
							# Navigate to Central installation directory [D-Drive] and install Client 32 Bit Version [Admin version, silent install option]
		


							$SourceDir="<APPROPRIATE_PATH>\Oracle21cClient\32Bit\client32"
							$Oracle21_setup = "$SourceDir\setup.exe"
							$OracleArgs = '-silent -ignoreSysPrereqs -ignorePrereqFailure -waitForCompletion -force -responseFile "<APPROPRIATE_PATH>\Oracle21cClient\32Bit\client32\response\oracle21_installclient-ddrive.rsp"'
    
							Start-Process $Oracle21_setup -ArgumentList $OracleArgs -Wait -NoNewWindow
                        

                        

							# Copy Over tnsnames.ora file and sqlnet.ora to Oracle 21c 32 bit and 32bit TNS_ADMIN locations
							# This will be done from the existing OracleXX Location as during installation the TNS Names is 
							# specific to environments [TEST / PROD / etc]. With the Oracle12c-Client installed this configuration is already in place.
							# This approach is predicated that 21c Clients will be installed before the Default Oracle12c Client is removed.
	
							xcopy /Y "$12cHloc\network\admin\tnsnames.ora" <APPROPRIATE_PATH>\client_1\network\admin\
							xcopy /Y "$12cHloc\network\admin\sqlnet.ora" <APPROPRIATE_PATH>\client_1\network\admin\

						}
						
						
						
						else
						{
							# Navigate to Central installation directory [C-Drive] and install Client 32 Bit Version [Admin version, silent install option]
		


							$SourceDir="<APPROPRIATE_PATH>\Oracle21cClient\32Bit\client32"
							$Oracle21_setup = "$SourceDir\setup.exe"
							$OracleArgs = '-silent -ignoreSysPrereqs -ignorePrereqFailure -waitForCompletion -force -responseFile "<APPROPRIATE_PATH>\Oracle21cClient\32Bit\client32\response\oracle21_installclient-cdrive.rsp"'
    
							Start-Process $Oracle21_setup -ArgumentList $OracleArgs -Wait -NoNewWindow
                        

                        

							# Copy Over tnsnames.ora file and sqlnet.ora to Oracle 21c 32 bit and 32bit TNS_ADMIN locations
							# This will be done from the existing Oracle12c Location as during installation the TNS Names is 
							# Specific to environments [TEST, PROD, etc]. With the Orace12c-Client installed this configuration is already in place.
							# This approach is predicated that 21c Clients will be installed before the Oracle12c Client is removed.
	
							xcopy /Y "$12cHloc\network\admin\tnsnames.ora" <APPROPRIATE_PATH>\client_1\network\admin\
							xcopy /Y "$12cHloc\network\admin\sqlnet.ora" <APPROPRIATE_PATH>\client_1\network\admin\

						}	# end of if ($d-drive_verify) / else
												
						

					} # end of elseif ( ($Hname -ne "OraClient21Home1") -and ($Hidx -eq $HomeLocationsCount))


					#Increment $HomeLocationsCurrent Counter for next pass 
					$HomeLocationsCurrent = $HomeLocationsCurrent + 1
					
					
			}	# End of foreach ($location in $HomeLocations)

			
		}  # End of foreach ($file in $RawXMLFile)
	


		
			# Copy Silent Install Result Summary to <APPROPRIATE_PATH>\Oracle21cClient\32Bit\
			if ($inventory_logs)
			{		
				C:
				cd "C:\Program Files (x86)\Oracle\Inventory\logs"
				
				$CentralResultsDir="<APPROPRIATE_PATH>\Oracle21cClient\"
				
				mkdir $CentralResultsDir\$Host_Name
				Copy-Item silentInstall*.log $CentralResultsDir\$Host_Name -Force -Recurse -Confirm:$false
	
			}
			
    } # end of if ($inventoryxml_32)


	else
	{
            $CentralResultsDir="<APPROPRIATE_PATH>\Oracle21cClient\"	
			mkdir $CentralResultsDir\$Host_Name

			write-host ====================================================================================================
			write-host
		    write-host "No Oracle Client 32 Bit Installed. Gracefully exiting."
            write-host
			write-host ====================================================================================================
			write-host

            Stop-transcript
            C:
            Copy-Item -Path "C:\Oracle21C32_Install.txt" "<APPROPRIATE_PATH>\Oracle21cClient\$Host_Name"
            Remove-Item -Path "C:\Oracle21C32_Install.txt" -Recurse -Force -Confirm:$false
			exit 0
	}


        Stop-transcript
        C:
        Copy-Item -Path "C:\Oracle21C32_Install.txt" "<APPROPRIATE_PATH>\Oracle21cClient\$Host_Name"
        Remove-Item -Path "C:\Oracle21C32_Install.txt" -Recurse -Force -Confirm:$false
}



catch {

    # for unknown errors. exit with Retry code 1618.
	
		write-host ====================================================================================================
		write-host
		Write-Host "Error with Oracle 21c 32 Bit Installation."
        write-host
		write-host ====================================================================================================
		write-host

		Stop-transcript
		C:
        Copy-Item -Path "C:\Oracle21C32_Install.txt" "<APPROPRIATE_PATH>\Oracle21cClient\$Host_Name"
        Remove-Item -Path "C:\Oracle21C32_Install.txt" -Recurse -Force -Confirm:$false
		
		exit 1618
}