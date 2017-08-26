<#
Name: get-oktaGroupMembers.ps1
Purpose: Script for exporting Okta group membership to a csv file
Author: Chris Neely
E-mail: chris@neely.pro
Notes: Requires PowerShell3.0 or later
Example: .\get-oktaGroupMembers.ps1 -org "tenant.okta.com" -gid "0000" -api_token "0000" -path "c:\scripts\groupname.csv"
#>

#requires -version 3.0

param(
    [Parameter(Mandatory=$true)]$org, # Your tentant prefix - Ex. tenant.okta.com
    [Parameter(Mandatory=$true)]$gid, # The group ID for the group you want to export - Ex. https://tenant-admin.okta.com/admin/group/00000000000000000000
    [Parameter(Mandatory=$true)]$api_token, # Your API Token.  You can generate this from Admin - Security - API
    [Parameter(Mandatory=$true)]$path # The path and file name for the resulting CSV file
    )

### Define $allusers as empty array
$allusers = @()

$headers = @{"Authorization" = "SSWS $api_token"; "Accept" = "application/json"; "Content-Type" = "application/json"}

### Set $uri as the API URI for use in the loop
$uri = "https://$org/api/v1/groups/$gid/users"

### Use a while loop and get all users from Okta API
do {
    $webresponse = Invoke-WebRequest -Headers $headers -Method Get -Uri $uri
    $links = $webresponse.Headers.Link.Split("<").Split(">") 
    $uri = $links[3]
    $users = $webresponse | ConvertFrom-Json
    $allusers += $users
} while ($webresponse.Headers.Link.EndsWith('rel="next"'))

### Filter the results and remove any DEPROVISIONED users
$activeUsers = $allusers | Where-Object { $_.status -ne "DEPROVISIONED" }

### Select the user profile properties we want and export to CSV
$activeUsers | Select-Object -ExpandProperty profile | 
    Select-Object -Property email, displayName, primaryPhone, mobilePhone, organization, department | 
    Export-Csv -Path $path -NoTypeInformation
