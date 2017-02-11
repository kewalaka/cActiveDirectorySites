function Get-TargetResource {
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Site,

        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present', 

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $result = Get-ADReplicationSubnet -Filter {Name -eq $Name} -Credential $Credential

    if($result) {
        Write-Verbose "Found $Name subnet"
        $Ensure = 'Present'        
    }
    else {
        Write-Verbose "$Name subnet not present"
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
        [string]$Site,

        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present', 

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $null = $PSBoundParameters.Remove('Debug')
    $null = $PSBoundParameters.Remove('Ensure')  

    if($Ensure -eq 'Present') {
        Write-Verbose "Creating new AD subnet $Name"
        New-ADReplicationSubnet @PSBoundParameters    
    }
    else {
        Write-Verbose "Removing AD subnet $Name"
        Get-ADReplicationSubnet -Filter {Name -eq $Name} -Credential $Credential | Remove-ADReplicationSubnet -Credential $Credential
    }
}

function Test-TargetResource {
	[CmdletBinding()]
	[OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Site,

        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present', 

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $null = $PSBoundParameters.Remove("Debug")
    $resource = Get-TargetResource @PSBoundParameters

    if($resource.Ensure -eq 'present' -and $Ensure -eq 'Present'){
        Write-Verbose "$Name subnet is present"
        Write-Output $true        
    }
    else {    
        Write-Verbose "$Name subnet not present or Ensure = 'Absent'"  
        Write-Output $false         
    }
}