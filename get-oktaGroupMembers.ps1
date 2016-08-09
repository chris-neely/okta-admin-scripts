<#
Name: get-oktaGroupMembers.ps1
Purpose: Script for exporting Okta group membership to a csv file
Author: Chris Neely
E-mail: chris@chrisneely.tech
Notes: Requires PowerShell3.0 or later
Example: .\get-oktaGroupMembers.ps1 -org "tenant" -gid "0000000000" -api_token "0000000000" -outfile "c:\scripts\groupname.csv"
#>

#requires -version 3.0

param(
    [Parameter(Mandatory=$true)]$org, # Your tentant prefix - Ex. tenant.okta.com
    [Parameter(Mandatory=$true)]$gid, # The group ID for the group you want to export - Ex. https://tenant-admin.okta.com/admin/group/00000000000000000000
    [Parameter(Mandatory=$true)]$api_token, # Your API Token.  You can generate this from Admin - Security - API
    [Parameter(Mandatory=$true)]$outfile # The path and file name for the resulting CSV file
    )

### Define $allusers and $selectedUsers as empty arrays
$allusers = @()
$selectedUsers = @()

### Set $uri as the API URI for use in the loop
$uri = "https://$org.okta.com/api/v1/groups/$gid/users"

### Use a while loop and get all users from Okta API
DO
{
$webrequest = Invoke-WebRequest -Headers @{"Authorization" = "SSWS $api_token"} -Method Get -Uri $uri
$link = $webrequest.Headers.Link.Split("<").Split(">") 
$uri = $link[3]
$json = $webrequest | ConvertFrom-Json
$allusers += $json
} while ($webrequest.Headers.Link.EndsWith('rel="next"'))

### Filter the results and remove any DEPROVISIONED users
$activeUsers = $allusers | Where-Object { $_.status -ne "DEPROVISIONED" }

### Select the user profile properties we want and export to CSV
$activeUsers | Select-Object -ExpandProperty profile | Select-Object -Property email, displayName, primaryPhone, mobilePhone, organization, department | Export-Csv -Path $outfile -NoTypeInformation
