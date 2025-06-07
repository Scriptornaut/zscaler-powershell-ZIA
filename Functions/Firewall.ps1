function Get-ZscalerFirewallRule
{
    <#
    .SYNOPSIS
    Gets Firewall Filtering Rules

    .PARAMETER id
    Retrieve a Firewall rule by its ID number

    .EXAMPLE
    PS> Get-ZscalerFirewallRule -id 12345
    #>
    param(
        [Parameter(Mandatory=$false)][string]$id
    )

    $request = [System.UriBuilder]("https://admin.{0}.net/api/v1/firewallFilteringRules" -f $global:ZscalerEnvironment.cloud)

    if ($id) {
        $request.Path += ("/{0}" -f $id)
    }

    return Invoke-RestMethod -uri $request.Uri -Method Get -WebSession $global:ZscalerEnvironment.webession -Body $parameters -ContentType 'application/json'
}

function Add-ZscalerFirewallRule
{
    <#
    .SYNOPSIS
    Adds a new Firewall Filtering Rule

    .PARAMETER name
    Name for the rule

    .PARAMETER order
    Rule order

    .PARAMETER action
    Rule action. ALLOW or DROP

    .PARAMETER protocols
    Protocols for which the rule applies (ex. ANY_RULE)

    .PARAMETER rank
    Admin rank. Defaults to 7 if not specified

    .PARAMETER state
    Rule state. Enabled or Disabled

    .PARAMETER srcIpGroups
    Source IP groups for the rule

    .PARAMETER destIpGroups
    Destination IP groups for the rule

    .EXAMPLE
    PS> Add-ZscalerFirewallRule -name "New Rule" -order 1 -action ALLOW -protocols ANY_RULE
    #>
    param(
        [Parameter(Mandatory=$true)][string]$name,
        [Parameter(Mandatory=$true)][int]$order,
        [Parameter(Mandatory=$true)][string]$action,
        [Parameter(Mandatory=$true)][string[]]$protocols,
        [Parameter(Mandatory=$false)][int]$rank,
        [Parameter(Mandatory=$false)][string]$state,
        [Parameter(Mandatory=$false)][string[]]$srcIpGroups,
        [Parameter(Mandatory=$false)][string[]]$destIpGroups
    )

    $parameters = [ordered]@{}
    $parameters.Add('name', $name)
    $parameters.Add('order', $order)
    if ($rank) { $parameters.Add('rank', $rank) } else { $parameters.Add('rank', 7) }
    if ($state) { $parameters.Add('state', $state) } else { $parameters.Add('state', 'ENABLED') }
    $parameters.Add('action', $action)
    $parameters.Add('protocols', $protocols)
    if ($srcIpGroups) { $parameters.Add('srcIpGroups', $srcIpGroups) }
    if ($destIpGroups) { $parameters.Add('destIpGroups', $destIpGroups) }

    $request = [System.UriBuilder]("https://admin.{0}.net/api/v1/firewallFilteringRules" -f $global:ZscalerEnvironment.cloud)

    return Invoke-RestMethod -uri $request.Uri -Method Post -WebSession $global:ZscalerEnvironment.webession -Body (ConvertTo-Json $parameters) -ContentType 'application/json'
}

function Remove-ZscalerFirewallRule
{
    <#
    .SYNOPSIS
    Removes a Firewall Filtering rule

    .PARAMETER id
    The ID number of the rule to remove

    .EXAMPLE
    PS> Remove-ZscalerFirewallRule -id 12345
    #>
    param(
        [Parameter(Mandatory=$true)][string]$id
    )

    $request = [System.UriBuilder]("https://admin.{0}.net/api/v1/firewallFilteringRules" -f $global:ZscalerEnvironment.cloud)

    $request.Path += ("/{0}" -f $id)

    return Invoke-RestMethod -uri $request.Uri -Method Delete -WebSession $global:ZscalerEnvironment.webession -Body $parameters -ContentType 'application/json'
}
