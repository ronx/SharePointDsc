function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $false)] [System.Management.Automation.PSCredential] $InstallAccount,
        [parameter(Mandatory = $true)] [System.String] $MailAddress,
        [parameter(Mandatory = $true)] [ValidateRange(0,356 )] [System.UInt32] $DaysBeforeExpiry,
        [parameter(Mandatory = $true)][ValidateRange(0,36000 )]  [System.UInt32] $PasswordChangeWaitTimeSeconds,
		[parameter(Mandatory = $true)][ValidateRange(0,99 )] [System.UInt32] $NumberOfRetries
    )

    Write-Verbose -Message "Retrieving farm wide automatic password change settings"

    $result = Invoke-xSharePointCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
        $params = $args[0]
        
        $farm = Get-SPFarm
        if ($null -eq $farm ) { return $null }
        return @{

		MailAddress = $farm.PasswordChangeEmailAddress
		PasswordChangeWaitTimeSeconds= $farm.PasswordChangeGuardTime
		NumberOfRetries= $farm.PasswordChangeMaximumTries
		DaysBeforeExpiry = $farm.DaysBeforePasswordExpirationToSendEmail 
        }
    }
    return $result
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $false)] [System.Management.Automation.PSCredential] $InstallAccount,
        [parameter(Mandatory = $true)] [System.String] $MailAddress,
        [parameter(Mandatory = $true)] [ValidateRange(0,356 )] [System.UInt32] $DaysBeforeExpiry,
        [parameter(Mandatory = $true)][ValidateRange(0,36000 )]  [System.UInt32] $PasswordChangeWaitTimeSeconds,
		[parameter(Mandatory = $true)][ValidateRange(0,99 )] [System.UInt32] $NumberOfRetries        
    )

    Write-Verbose -Message "Updating farm wide automatic password change settings"
    Invoke-xSharePointCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
        $params = $args[0]
        
        <#$updateParams = @{ 
            PasswordChangeEmailAddress = $params.MailAddress
			DaysBeforePasswordExpirationToSendEmail = $params.DaysBeforeExpiry
			PasswordChangeMaximumTries = $params.NumberOfRetries
			PasswordChangeGuardTime = $params.PasswordChangeWaitTimeSeconds
			 
        }#>
		$farm = Get-SPFarm
		$farm.PasswordChangeEmailAddress=$params.MailAddress;
		$farm.PasswordChangeGuardTime=$params.PasswordChangeWaitTimeSeconds
		$farm.PasswordChangeMaximumTries=$params.NumberOfRetries
		$farm.DaysBeforePasswordExpirationToSendEmail =$params.DaysBeforeExpiry
		$farm.Update();
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $false)] [System.Management.Automation.PSCredential] $InstallAccount,
        [parameter(Mandatory = $true)] [System.String] $MailAddress,
        [parameter(Mandatory = $true)] [ValidateRange(0,356 )] [System.UInt32] $DaysBeforeExpiry,
        [parameter(Mandatory = $true)][ValidateRange(0,36000 )]  [System.UInt32] $PasswordChangeWaitTimeSeconds,
		[parameter(Mandatory = $true)][ValidateRange(0,99 )] [System.UInt32] $NumberOfRetries
	)

    $CurrentValues = Get-TargetResource @PSBoundParameters
    Write-Verbose -Message "Testing retrieving farm wide automatic password change settings"
	if ($null -eq $CurrentValues) { return $false }
	
    return Test-xSharePointSpecificParameters -CurrentValues $CurrentValues -DesiredValues $PSBoundParameters -ValuesToCheck @("MailAddress", "DaysBeforeExpiry","PasswordChangeWaitTimeSeconds","NumberOfRetries") 
}


Export-ModuleMember -Function *-TargetResource

