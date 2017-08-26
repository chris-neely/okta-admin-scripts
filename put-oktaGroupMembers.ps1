<#
Name: put-oktaGroupMembers.ps1
Purpose: Script for adding a csv file of user email addresses to an Okta group
Author: chris@neely.pro
Notes: Requires PowerShell 3.0 or later
Example: .\put-oktaGroupMembers.ps1 -org "tenant.okta.com" -gid "0000" -api_token "0000" -path "c:\scripts\groupname.csv"
#>

#requires -version 3.0

param(
    [Parameter(Mandatory=$true)]$org, # Your tentant prefix - Ex. tenant.okta.com
    [Parameter(Mandatory=$true)]$gid, # The group ID for the group you want to export - Ex. https://tenant-admin.okta.com/admin/group/00000000000000000000
    [Parameter(Mandatory=$true)]$api_token, # Your API Token.  You can generate this from Admin - Security - API
    [Parameter(Mandatory=$true)]$path # The path and file name for the CSV file of user email addresses
    )

### Define headers for web request
$headers = @{"Authorization" = "SSWS $api_token"; "Accept" = "application/json"; "Content-Type" = "application/json"}

### Import csv file
$userlist = Import-CSV -Path "$path" -Header "email"

### Loop through each item in the list
foreach ($user in $userlist) {
    ### Variable for user's email address
    $email = $user.email

    try {
        ### Lookup user by email address and stop processing if the user is not found
        $webrequest = Invoke-WebRequest -Headers $headers -Method Get -Uri "https://$org/api/v1/users/$email" -ErrorAction:Stop

        ### Parse JSON from webrequest
        $json = $webrequest | ConvertFrom-Json

        ### Set the user's uid
        $uid = $json | Select-Object -ExpandProperty id

        try {
            ### Add the user to the group using their uid and stop processing if it fails
            $result = Invoke-WebRequest -Headers $headers -Method Put -Uri "https://$org/api/v1/groups/$gid/users/$uid" -ErrorAction:Stop
            
            ### Write message if adding the user to the group was successful
            if ( $result.StatusCode -eq 204 ) { Write-Output "Successfully added $($user.email)" }
        } catch {
            ### Write message if adding the user to the group fails
            Write-Output "Failed adding user $($user.email) to group - error: $($_.Exception.Response.StatusCode.Value__)"
        }
    } catch {
        ### Write message if user is not found
        Write-Output "Failed looking up user $($user.email) - error: $($_.Exception.Response.StatusCode.Value__)"
    }
    
    ### clear variables every loop iteration
    $email = ""
    $webrequest = ""
    $json = ""
    $uid = ""
    $result = ""
}