# This sets up a menu for a better user experience. 

Clear-Host
Write-Host -ForegroundColor Cyan "                                                                                                  
                                                                                                                                           
                                          ......::--====--::......                                  
                                      ..:-+**********************+-:..                              
                                  ..:=********************************-..                           
                               ..:+**************************+++=-::..:::                           
                              .-************************+=:.                                        
                ..:--======--=*********************+=-.                                             
            .:-+********************************+-.                                                 
         ..=*********************************+-....----======---.                                   
        :+*********************************+::==***********+=-.                                     
      .+***********************************************+-:.           ....:------:....              
    .-**********************************************=-.        ..:-==+****************+=-..         
   .=********************************************=:.        .-=+**************************+=:.      
  .=******************************************+:.       .:=+*********************************+-.    
 .-*****************************************-.        .=+*************++++*********************+:   
.:***************************************+:.        .+*****+:::...           ..::=***************:. 
.=**************************************..        .=**-....                       ..-*************:.
.*************************************.          ::...                               .:***********=.
:***********************************:                                                  :+**********.
:*********************************=.                                                    -**********:
.********************************=                                                     .=**********:
.+******************************.                     .................               .-**********+.
.-****************************+.                ..::=*******************+::..       .:+***********:.
 .=**************************+.             .::*********************************+****************-. 
  :+************************+.          .:-+***************************************************=.   
   .=**********************+:        .:-****************************************************+=.     
    .-********************+:       .:***************************************************+=-.        
      .=******************-.    ..=************************************************-:...            
        .=+**************+.    .=*************************************************-.                
          .:=+***********-   .=*************************************************+:.                 
             ..:-=+****+=. .-*************************************************+:.                   
                   ....    .:=**********************************************+:.                     
                             ..:+****************************************+-..                       
                                .....:::...-+*************************-:..                          
                                            ...::=+************+=-:...                              
                                                   ............                                                                                                                                         
                                                                                                
                                                [*] Welcome to the ZIA API Helper Tool.`n"


# Some ideas for this script
# Print out a list of functions with a note on getting more infor with get-command "cmdlet name"
# If changes are made, determine if it we need to activate the changes to reflect in ZIA

function Get-Menu {
  Write-Host "`nPick an option below to get started."
  Write-Host "1. Create a new API Session"
  Write-Host "2. List Zscaler Commands"
  Write-Host "3. exit"

  $choice = Read-Host -Prompt "Type an option number`n`t> "
  if ($choice -eq 1) {
    # Action to perform if the user selects option 1
    try {
        # Attempt to set up the Zscaler environment
        Set-ZscalerEnvironment
        Get-ZscalerAPISession
    }
    catch {
        # Handle exceptions if Set-ZscalerEnvironment fails
        Write-Host -ForegroundColor Red "[!] Something went wrong setting up your session. Check your credientials and try again."
        }
        
    #     else {
    #         Write-Host -ForegroundColor Red "[!] Could not locate the Zscaler module. Please ensure it is downloaded and placed in an accessible directory."
    #     }
     }
  elseif ($choice -eq 2) {
    Get-Command -Module zscaler
    Get-Menu
  }
  elseif ($choice -eq 3) {
    Write-Host "`n`t`tHave a great day!`n"
  }
}

Write-Host -ForegroundColor DarkCyan "`n[*] Checking if the Zscaler PowerShell module is loaded in your profile."

#Logic to check for module
if (Get-Module -Name Zscaler) {
  Start-Sleep(1)  
  Write-Host -ForegroundColor Green "[+] The Zscaler module is loaded."
  Start-Sleep(1)
  Write-Host -ForegroundColor DarkCyan "[*] Checking for an existing session..."
  Start-Sleep(1)
    try {
    Get-ZscalerSessionCookie
        }
    catch {
      <#Do this if a terminating exception happens#>
      Write-Host -ForegroundColor Red "[!] No Active Session."
      Get-Menu
        }
      }
else {
    Start-Sleep(2)
    Write-Host -ForegroundColor Red "[!] The Zscaler module is not loaded."
    Write-Host -ForegroundColor Yellow "[*] Attempting to locate and load the module . . ."
    Start-Sleep(2)
    # Store the current directory path
    $ScriptDir = Get-Location
    Set-Location -Path ..  # Move up one directory to search for the module
    # Find the Zscaler module
    
    $module = Get-ChildItem -Recurse -Filter "zscaler.psd1" -ErrorAction SilentlyContinue | Select-Object -First 1
    # Return to the original directory
    Set-Location -Path $ScriptDir
    
    if ($module) {
        # Import the module using the correct path
        Import-Module -Name $module.PSPath -ErrorAction Stop
        Write-Host -ForegroundColor Green "[+] Successfully imported the Zscaler PowerShell Module!"
    
        # Prompt user to permanently import the module
        $option = Read-Host -Prompt "[?] Want to permanently import the module for future use? (y/n):`n> "
        if ($option -eq 'y') {
            # Remove the Microsoft prefix and store the path
            $modulePath = $module.PSPath -replace '^Microsoft.PowerShell.Core\\FileSystem::', ''
            Write-Output "`nImport-Module -Name `"$modulePath`"" >> $PROFILE
            Write-Host -ForegroundColor Green "[+] Module added to your PowerShell profile for future use."
        }
    } else {
        Write-Host -ForegroundColor Red "[!] Couldn't locate the module file."
    }    
# Display the menu
Get-Menu
}

