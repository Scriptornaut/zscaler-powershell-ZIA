﻿function Get-ZscalerAPISession
{
    <#
    .SYNOPSIS

    Logs into the Zscaler API and gets an active session

    .EXAMPLE

    PS> Get-ZscalerAPISession
    #>

    $cloud = $global:ZscalerEnvironment.cloud
    $apikey = $global:ZscalerEnvironment.apikey
    $username = $global:ZscalerEnvironment.username
    $password = $global:ZscalerEnvironment.password

    
    $encAPIstr = (ConvertFrom-SecureString -SecureString $apikey)
    $encPassword = (ConvertFrom-SecureString -SecureString $password) 

    #
    # set the URI
    #
    $uri = ("https://admin.{0}.net/api/v1/authenticatedSession" -f $cloud)

    #
    # set up obfuscation, timestamps, and all of this other mess
    #
    $date = (get-date).ToUniversalTime()
    $instant = [decimal](get-date -date $date -UFormat %s)
    $now = [math]::Truncate($instant * 1000)
    $length = ([string]$now).Length
    $n = ([string]$now).Substring($length - 6)
    $r = ([string]($n -shr 1)).PadLeft(6, '0')

    #
    # construct the secret
    # Need to convert the secure string to plaintext in memory

    $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((($encPassword | ConvertTo-SecureString))))
    $apiKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((($encAPIstr | ConvertTo-SecureString))))

    #
    $secret = ""
    try {
        [char[]]$n | ForEach-Object {
            $secret += $apikey.Substring([string]$_, 1)
        }

        if ($r.Length -lt 6) {$r = $r.PadLeft(6, '0') ; write-host "WARNING: Had to fix padding. Please report this issue to the developer." }
        [char[]]$r | ForEach-Object {
            $position = ([int]([string]$_)) + 2
            $secret += $apikey.Substring($position, 1)
        }
    }
    catch {
        Write-Host "Exception occurred while generating the API Secret. Please report this issue to the developer."
        write-host "r is .$r."
        write-host "position is $position"
        write-host "secret is $secret"
        write-host "var is $_"
    }
    

    #
    # construct our parameters variable. Plain Strings
    #
    $parameters = @{
        apiKey = $secret
        username = $username
        password = $password
        timestamp = $now.ToString()
    }

    #
    # send login request
    #
    $result = Invoke-RestMethod -Uri $uri -Method Post -Body (ConvertTo-Json $parameters) -ContentType "application/json" -SessionVariable webession
    $global:ZscalerEnvironment.webession = $webession
}

function Remove-ZscalerAPISession
{
    <#
    .SYNOPSIS

    Logs out of the Zscaler API session

    .EXAMPLE

    PS> Remove-ZscalerAPISession
    #>

    # set the URI
    $uri = ("https://admin.{0}.net/api/v1/authenticatedSession" -f $global:ZscalerEnvironment.cloud)

    # log out of the authenticated session
    $result = Invoke-RestMethod -Uri $uri -Method Delete -WebSession $global:ZscalerEnvironment.webession -ContentType 'application/json'
    return
}

function Get-ZscalerEnvironmentFromFile
{
    <#
    .SYNOPSIS

    Reads Zscaler API Environment information from a file, then feeds to Set-ZscalerEnvironment

    .EXAMPLE

    PS> Get-ZscalerEnvironmentFromFile -FileName .\.Zscaler\config
    
    .PARAMETER FileName

    File name containing the Zsclaer API environment variables. Example file looks like this:
    cloud = zscalerthree
    apikey = ABCDEFGHIJ
    username = admin@123.zscalerthree.net
    password = P4ssw0rd

    #>
    param(
        [Parameter(Mandatory=$false)][string]$FileName
    )

    # try to read from the default location of $HOME/.Zscaler/config if no FileName was specified. If this file does not exist, throw an error
    if (!$FileName)
    {
        if (Test-Path -Path $HOME/.Zscaler/config)
        {
            # config file exists
            $FileName = "$HOME/.Zscaler/config"
        } else {
            # conf file does not exist. Since they didn't specify a file and there's no default config, throw an error
            Throw "Must specify -FileName or have a config file at $HOME/.Zscaler/config"
        }
    }

    # read in the configuration file
    $environment = ConvertFrom-StringData -StringData (Get-Content -path $FileName -Raw)

    # set the environment
    Set-ZscalerEnvironment -cloud $environment.cloud -apikey $environment.apikey -username $environment.username -password $environment.password
}

function Set-ZscalerEnvironment
{
    <#
    .SYNOPSIS

    Sets the variables required to authenticate to the Zscaler API

    .EXAMPLE 

    PS> Set-ZscalerEnvironment -cloud zscalerthree -apikey ABCDEFGHIJ -username admin@123.zscalerthree.net -password P4ssw0rd

    .PARAMETER cloud
    The Zscaler cloud you are logging into. Example: zscalerthree

    .PARAMETER apikey
    Your Zscaler Cloud API Key

    .PARAMETER username
    Your Zscaler API username

    .PARAMETER password
    Your Zscaler API password
    #>
    param(
        [Parameter(Mandatory=$true)][string]$cloud,
        [Parameter(Mandatory=$true)][securestring]$apikey,
        [Parameter(Mandatory=$true)][string]$username,
        [Parameter(Mandatory=$true)][securestring]$password
    )

    # $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    # $apiKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($apikey))
    
    $global:ZscalerEnvironment = [PSCustomObject]@{
        cloud =  $cloud
        username = $username
        password = $password 
        apikey = $apikey 
        webession = $webession
    }
}

function Get-ZscalerSessionCookie
{
    <#
    .SYNOPSIS

    Outputs the Zscaler API session cookie value if one exists

    .EXAMPLE

    PS> Get-ZscalerSessionCookie
    JSESSIONID=1E62Z35CE94DC34A801DC822D6CEEC1R
    #>
    $uri = ("https://admin.{0}.net/api/v1/authenticatedSession" -f $global:ZscalerEnvironment.cloud)
    return $Global:ZscalerEnvironment.webession.Cookies.GetCookies($uri)[0].ToString()
}