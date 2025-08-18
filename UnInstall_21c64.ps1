########################################################################################################
#	
#	FileName:		UnInstall_21c64.ps1
#	Author:			Christophe Cartwright, Oracle DBA
#	Date:			
#	Version:		1.0
#	Description:	Shell Script Vets for Oracle_Homes (from inventory.xmls)
# 					Depending on checks, Oracle 21c [64] will be Dynamically uninstalled  in Silent Mode
#
#	Acknowlegements: 	(Jason Bergner) https://silentinstallhq.com/oracle-database-19c-client-install-and-uninstall-powershell/
#						
#						
#
#	Revision History:
#	Revisionist:
#
########################################################################################################





try{

    Start-transcript -Path "C:\Oracle21C64_UnInstall.txt"

    $CentralResultsDir="<APPROPRIATE_PATH>\Oracle21cClientDeinstall\"
	$Host_Name = hostname
	$Current_Date = Get-Date -Format "yyyy-MM-dd"		 

	
	$inventoryxml_64 = Test-Path -Path "C:\Program Files\Oracle\Inventory\ContentsXML\inventory.xml" -PathType Leaf
	$inventory_logs = Test-Path -Path "C:\Program Files\Oracle\Inventory\logs\*"  -PathType Leaf
	

	
	if ($inventoryxml_64)
	{
	
		$RawXMLFile = get-childitem 'C:\Program Files\Oracle\Inventory\ContentsXML' -file -include inventory.xml -Recurse

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
						write-host "Oracle21c 64bit Client installed. Proceeding to uninstall Oracle21c 64bit Client. "
						write-host
						write-host "Oracle name is: " $Hname
						write-host "Oracle home is: " $Hloc
						write-host
						write-host
						write-host ====================================================================================================
						write-host


						#Dynamically Generate 21c Client Deinstall Response File
						$Oracle21c_Deinstall_Exe = "$Hloc\deinstall\deinstall.bat"
						$OracleArgs = '-silent -checkonly -o C:\'						
						Start-Process $Oracle21c_Deinstall_Exe -ArgumentList $OracleArgs -Wait -NoNewWindow
                        

						# Test for existing of Deinstall Response file
						$Oracle21c_Deinstall_RspFile = Test-Path -Path "C:\deinstall_OraClient21Home1.rsp"  -PathType Leaf
						

						if ($Oracle21c_Deinstall_RspFile)
						{
							#Stop Any Oracle Client Services (as we are rolling back there has been an impact on the Previous Oracle Client
							Stop-Service -DisplayName "Ora*" | Where-Object {$_.Status -eq "Running"} |Where{$_.StartType -eq "Automatic"} 
							
							# Navigate to Central installation directory and uninstall Client 32 Bit Version [Admin version, silent install option]
							$Oracle21c_Deinstall_Exe = "$Hloc\deinstall\deinstall.bat"						
							$OracleArgs = '-silent -paramfile C:\deinstall_OraClient21Home1.rsp'							
							Start-Process $Oracle21c_Deinstall_Exe -ArgumentList $OracleArgs -Wait -NoNewWindow
							Remove-Item -Path "C:\deinstall_OraClient21Home1.rsp" -Recurse -Force -Confirm:$false
							
							#Start Any Oracle Client Services (as we are rolling back there has been an impact on the Previous Oracle Client
							Start-Service -DisplayName "Ora*" | Where-Object {$_.Status -eq "Stopped"} |Where{$_.StartType -eq "Automatic"} 
							
						} 
							
							
						else
						{
							write-host ====================================================================================================
							write-host
							write-host "No Oracle 21c 64 Client Response File Generated. An issue occurred. Please investigate. Exiting."
							write-host
							write-host ====================================================================================================
							write-host
							
							Stop-transcript                      
                            		
                            $CentralResultsDir_HostName = Test-Path -Path "$CentralResultsDir\$Host_Name" 

                            if($CentralResultsDir_HostName){

							    C:
							    Copy-Item -Path "C:\Oracle21C64_UnInstall.txt" "$CentralResultsDir\$Host_Name"
							    Remove-Item -Path "C:\Oracle21C64_UnInstall.txt" -Recurse -Force -Confirm:$false
							    exit 1618
                            }

                            else{
                            	mkdir $CentralResultsDir\$Host_Name
                            	C:
							    Copy-Item -Path "C:\Oracle21C64_UnInstall.txt" "$CentralResultsDir\$Host_Name"
							    Remove-Item -Path "C:\Oracle21C64_UnInstall.txt" -Recurse -Force -Confirm:$false
							    exit 1618

                            }
							
						} # end of if ($Oracle21c_Deinstall_RspFile) / else
						
						

						
					}  # end of if ($Hname -like "OraClient21Home*")
			
			
			
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
						write-host "If required, contact Oracle DBAs for guidance (Note: A ServiceNow Ticket will be required)."
						write-host "Continuing search for Oracle21c 64bit Client."
						write-host
						write-host ====================================================================================================
						write-host
				
					} #end of elseif ( ($Hname -notlike "OraClient21Home*") -and ($HomeLocationsCurrent -ne $HomeLocationsCount))
			

					elseif ( ($Hname -notlike "OraClient21Home*") -and ($HomeLocationsCurrent -eq $HomeLocationsCount))
					{
																	
						write-host ====================================================================================================
						write-host
						write-host "No Oracle Client 64Bit Installed. Gracefully exiting."
						write-host
						write-host ====================================================================================================
						write-host
							
						Stop-transcript

                        $CentralResultsDir_HostName = Test-Path -Path "$CentralResultsDir\$Host_Name" 

                        if($CentralResultsDir_HostName){

							    C:
							    Copy-Item -Path "C:\Oracle21C64_UnInstall.txt" "$CentralResultsDir\$Host_Name"
							    Remove-Item -Path "C:\Oracle21C64_UnInstall.txt" -Recurse -Force -Confirm:$false
							    exit 0
                         }

                         else{
                            	mkdir $CentralResultsDir\$Host_Name
                            	C:
							    Copy-Item -Path "C:\Oracle21C64_UnInstall.txt" "$CentralResultsDir\$Host_Name"
							    Remove-Item -Path "C:\Oracle21C64_UnInstall.txt" -Recurse -Force -Confirm:$false
							    exit 0

                         }
                            	

						

					} # end of elseif ( ($Hname -ne "OraClient21Home1") -and ($HomeLocationsCurrent -eq $HomeLocationsCount))


					#Increment $HomeLocationsCurrent Counter for next pass 
					$HomeLocationsCurrent = $HomeLocationsCurrent + 1
					
					
			}	# End of foreach ($location in $HomeLocations)

			
		}  # End of foreach ($file in $RawXMLFile)
	


		
		
		# Copy Silent UnInstall Result Summary to <APPROPRIATE_PATH>
		if ($inventory_logs)
		{		

            $CentralResultsDir_HostName = Test-Path -Path "$CentralResultsDir\$Host_Name" 

            if($CentralResultsDir_HostName){

			    C:
			    cd "C:\Program Files\Oracle\Inventory\logs"
			    Copy-Item Cleanup$Current_Date*.log $CentralResultsDir\$Host_Name -Force -Recurse -Confirm:$false
			    Copy-Item deinstall*$Current_Date*.* $CentralResultsDir\$Host_Name -Force -Recurse -Confirm:$false


                Stop-transcript
                C:
                Copy-Item -Path "C:\Oracle21C64_UnInstall.txt" "$CentralResultsDir\$Host_Name"
                Remove-Item -Path "C:\Oracle21C64_UnInstall.txt" -Recurse -Force -Confirm:$false

            }

             else{
                mkdir $CentralResultsDir\$Host_Name
			    
                C:
			    cd "C:\Program Files\Oracle\Inventory\logs"
			    Copy-Item Cleanup$Current_Date*.log $CentralResultsDir\$Host_Name -Force -Recurse -Confirm:$false
			    Copy-Item deinstall*$Current_Date*.* $CentralResultsDir\$Host_Name -Force -Recurse -Confirm:$false

                Stop-transcript
                C:
                Copy-Item -Path "C:\Oracle21C64_UnInstall.txt" "$CentralResultsDir\$Host_Name"
                Remove-Item -Path "C:\Oracle21C64_UnInstall.txt" -Recurse -Force -Confirm:$false

            }

	
		} # end of if ($inventory_logs)
	
	
	
    } # end of if ($inventoryxml_64)


	else
	{


		     write-host ====================================================================================================
		     write-host
		     write-host "No Oracle Client 64Bit Installed. Gracefully exiting."
		     write-host
		     write-host ====================================================================================================
		     write-host

            $CentralResultsDir_HostName = Test-Path -Path "$CentralResultsDir\$Host_Name" 

            if($CentralResultsDir_HostName){


                Stop-transcript
                C:
                Copy-Item -Path "C:\Oracle21C64_UnInstall.txt" "$CentralResultsDir\$Host_Name"
                Remove-Item -Path "C:\Oracle21C64_UnInstall.txt" -Recurse -Force -Confirm:$false
			    exit 0
            }


            else{


                mkdir $CentralResultsDir\$Host_Name

                Stop-transcript
                C:
                Copy-Item -Path "C:\Oracle21C64_UnInstall.txt" "$CentralResultsDir\$Host_Name"
                Remove-Item -Path "C:\Oracle21C64_UnInstall.txt" -Recurse -Force -Confirm:$false
			    exit 0
            }

	}


  
}



catch {

    # for unknown errors. exit with Retry code 1618.

		write-host ====================================================================================================
		write-host
		Write-Host "Error with Oracle 21c 64Bit UnInstallation."
        write-host
		write-host ====================================================================================================
		write-host

        $CentralResultsDir_HostName = Test-Path -Path "$CentralResultsDir\$Host_Name" 

        if($CentralResultsDir_HostName){

		    Stop-transcript
		    C:
            Copy-Item -Path "C:\Oracle21C64_UnInstall.txt" "$CentralResultsDir\$Host_Name"
            Remove-Item -Path "C:\Oracle21C64_UnInstall.txt" -Recurse -Force -Confirm:$false
		
		    exit 1618

        }

        else{

		    mkdir $CentralResultsDir\$Host_Name

		    Stop-transcript
		    C:
            Copy-Item -Path "C:\Oracle21C64_UnInstall.txt" "$CentralResultsDir\$Host_Name"
            Remove-Item -Path "C:\Oracle21C64_UnInstall.txt" -Recurse -Force -Confirm:$false
		
		    exit 1618

        }

}