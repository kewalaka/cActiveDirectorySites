function Get-TargetResource {
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$SitesIncluded,

        [Parameter(Mandatory=$false)]
        [string]$ReplicationFrequencyInMinutes,

        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present',

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $result = (Get-ADReplicationSiteLink -Filter {Name -eq $Name} -Credential $Credential).SitesIncluded -match $SitesIncluded

    if($result) {
        Write-Verbose "$SitesIncluded present in $Name" 
        $Ensure = 'Present'                   
    }
    else {
        Write-Verbose "$SitesIncluded not present in $Name"
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

        [Parameter(Mandatory)]
        [string]$SitesIncluded,

        [Parameter(Mandatory=$false)]
        [string]$ReplicationFrequencyInMinutes,

        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present',

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $null = $PSBoundParameters.Remove('Debug')
    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('Ensure')   

    if($Ensure -eq 'Present') {
        Write-Verbose "Adding $SitesIncluded to $Name"
        $null = $PSBoundParameters['SitesIncluded'] = @{add=$PSBoundParameters['SitesIncluded']}
        Get-ADReplicationSiteLink -Filter {Name -eq $Name} -Credential $Credential | Set-ADReplicationSiteLink @PSBoundParameters
    }   
    else {
        Write-Verbose "Removing $SitesIncluded to $Name"
        $null = $PSBoundParameters['SitesIncluded'] = @{remove=$PSBoundParameters['SitesIncluded']}
        Get-ADReplicationSiteLink -Filter {Name -eq $Name} -Credential $Credential | Set-ADReplicationSiteLink @PSBoundParameters    
    } 
}

function Test-TargetResource {
	[CmdletBinding()]
	[OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$SitesIncluded,

        [Parameter(Mandatory=$false)]
        [string]$ReplicationFrequencyInMinutes,

        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present',

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $null = $PSBoundParameters.Remove("Debug")
    $resource = Get-TargetResource @PSBoundParameters

    if($resource.Ensure -eq 'Present' -and $Ensure -eq 'Present'){        
        Write-Verbose "$SitesIncluded present in $Name"
        Write-Output $true 
    }
    else {
        Write-Verbose "$SitesIncluded not present in $Name or Ensure = 'Absent'"
        Write-Output $false
    }
}