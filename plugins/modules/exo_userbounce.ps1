#!powershell


## Copyright 2020 Colton Hughes <colton.hughes@firemon.com>

## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
  options = @{
    rule_name = @{ type = "str"; required = $true}
    user_email = @{ type = "str"; required = $true}
    mode = @{ type = "str"; choices = "append", "override"; default = "append" }
    condition = @{ type = "str"; choices = "sentTo", "from"; default = "sentTo" }
    exo_username = @{ type = "str"; required = $true }
    exo_password = @{type = "str"; required = $true; no_log = $true}
  }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$ruleName = $module.Params.rule_name
$userEmail = $module.Params.user_email
$mode = $module.Params.mode
$condition = $module.Params.condition
$exoUsername = $module.Params.exo_username
$exoPassword = $module.Params.exo_password

## Convert plaintext password to securestring
$secure_password = ConvertTo-SecureString -String $exoPassword -AsPlainText -Force

## Creating a secure reusable credential object
$credObject = New-Object System.Management.Automation.PSCredential ($exoUsername, $secure_password)

try {
  Import-Module ExchangeOnlineManagement
}
catch {
  $module.FailJson("Failed to import ExchangeOnlineManagement PowerShell module", $_)
  $module.Result.changed = $false
}


##Connect to Exchange Online
try
{
  Connect-ExchangeOnline -Credential $credObject -ShowBanner:$false
}
catch {
$module.FailJson("Could not Connect to ExchangeOnline", $_)
$module.Result.changed = $false
}

try {

## Fetch Current Transport Rule Recipients
$currentRecipients = (Get-transportRule $ruleName).$condition

if($currentRecipients.Contains($userEmail)){
  $module.Result.Changed = $false
  $module.ExitJson()
}

$module.Result.existing_recipients = $currentRecipients
$module.Result.rule_name = $ruleName

}
catch {
    $module.FailJson("Could not retrieve an existing rule with the provided settings", $_)
  }

## Add new user to the current recipient object
if ($mode -eq "append"){
  $currentRecipients += $userEmail
  $module.Result.new_recipients = $currentRecipients
}
else {
  $currentRecipients = $userEmail
}

## Modify transport rule
if($condition -eq "sentTo"){
  try{
    set-transportRule $ruleName -sentTo $currentRecipients
    $module.Result.changed = $true
  }
  catch {
    $module.FailJson("Could not modify the transport rule $ruleName", $_)
  }
}

if($condition -eq "from"){
  try{
    set-transportRule $ruleName -from $currentRecipients
    $module.Result.changed = $true
  }
  catch {
    $module.FailJson("Could not modify the transport rule $ruleName", $_)
  }
}

## Cleanup session
Disconnect-ExchangeOnline -Confirm:$false | out-null
$module.ExitJson()