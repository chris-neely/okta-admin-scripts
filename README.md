# okta-admin-scripts  
  
### get-oktaGroupMembers.ps1  
**Description:** PowerShell script to export Okta group membership to a CSV file  
**Example:** .\get-oktaGroupMembers.ps1 -org "tenant.okta.com" -gid "0000" -api_token "0000" -outfile "c:\scripts\file.csv"

### put-oktaGroupMembers.ps1
**Description:** PowerShell script for adding a CSV file of user email addresses to an Okta group  
**Example:** .\put-oktaGroupMembers.ps1 -org "tenant.okta.com" -gid "0000" -api_token"0000" -path "c:\scripts\file.csv"