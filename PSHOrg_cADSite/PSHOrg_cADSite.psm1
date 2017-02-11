function Get-TargetResource {
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present', 

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $result = Get-ADReplicationSite -Filter {Name -eq $Name} -Credential $Credential

    if($result) {
        Write-Verbose "Found AD Site $Name" 
        $Ensure = 'Present'       
    }
    else {
        Write-Verbose "Did not find AD Site $Name"
        $Ensure = 'Absent'
    }

    Write-Output @{
        Ensure = $Ensure
        Name = $Name
    }
}

function Set-TargetResource {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present', 

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $null = $PSBoundParameters.Remove('Debug')
    $null = $PSBoundParameters.Remove('Ensure')   

    if($Ensure -eq 'Present') {
       Write-Verbose "Creating new AD Site $Name"
       New-ADReplicationSite @PSBoundParameters 
    }
    else {
        Write-Verbose "Removing AD Site $Name"
        Get-ADReplicationSite -Filter {Name -eq $Name} -Credential $Credential | Remove-ADReplicationSite -Credential $Credential
    }
}

function Test-TargetResource {
	[CmdletBinding()]
	[OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present', 

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $null = $PSBoundParameters.Remove('Debug')
    $resource = Get-TargetResource @PSBoundParameters

    if($resource.Ensure -eq 'present' -and $Ensure -eq 'Present'){
        Write-Verbose "AD Site $Name is present"
        Write-Output $true        
    }
    else {
        Write-Verbose "$Name site not present or Ensure = 'Absent'"
        Write-Output $false 
    }
}