<#PSScriptInfo

.VERSION 1.0.0

.GUID 17a6476a-2e47-438b-9602-d36193fed386

.AUTHOR asheroto

.COMPANYNAME asheroto

.TAGS PowerShell Chrome Edge Browser Extension Management Install Remove Force Forcelist ExtensionInstallForcelist Block Blocklist ExtensionInstallBlocklist Unblock

.PROJECTURI https://github.com/asheroto/Manage-Browser-Extensions

#>

<#
.SYNOPSIS
    Utilities to manage browser extensions in Chrome and Edge. Block, unblock, install, force-install, and remove specified extensions.

.DESCRIPTION
    This PowerShell script provides functionality to manage specified browser extensions in Chrome and Edge by interacting with the Windows registry.

    The script allows administrators to:
    - Block specific extensions, preventing their installation.
    - Unblock extensions to allow installation if previously blocked.
    - Install extensions by adding them to the registry with an update URL.
    - Force-install extensions to enforce installation on users.
    - Remove extensions from Chrome and Edge.

    This script does not support Firefox or other browsers.

    Changes take effect without requiring a browser or system restart (except for force-installed extensions).

    Use Import-Module to load the script into your PowerShell session, then call the functions as needed.

.EXAMPLE
    Remove-Extension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
        Removes the specified extension from Chrome by deleting its registry entries.

.EXAMPLE
    Block-Extension -Browser "Edge" -ExtensionID "elhekieabhbkpmcefcoobjddigjcaadp"
        Adds the specified extension to the Edge blocklist, preventing installation.

.EXAMPLE
    Unblock-Extension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
        Removes the specified extension from Chrome’s blocklist, allowing installation.

.EXAMPLE
    Install-Extension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
        Installs the specified Chrome extension (update URL optional).

.EXAMPLE
    Force-InstallExtension -Browser "Edge" -ExtensionID "elhekieabhbkpmcefcoobjddigjcaadp"
        Forces installation of the specified extension in Edge.

.NOTES
    Version      : 1.0.0
    Author       : asheroto
    Permissions  : Administrator rights required for registry modifications.
.LINK
    Project Site: https://github.com/asheroto/Manage-Browser-Extensions
#>

# Updated custom object for storing extension information with all necessary paths
$extensionRegistryPaths = @{
    "Chrome" = [PSCustomObject]@{
        ForceInstallPath = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"
        InstallPath      = "HKLM:\SOFTWARE\Google\Chrome\Extensions"
        ExtensionPaths   = @(
            "HKLM:\SOFTWARE\WOW6432Node\Google\Chrome\Extensions",
            "HKLM:\SOFTWARE\Google\Chrome\Extensions"
        )
        UpdateUrl        = "https://clients2.google.com/service/update2/crx"
    }
    "Edge"   = [PSCustomObject]@{
        ForceInstallPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist"
        InstallPath      = "HKLM:\SOFTWARE\Microsoft\Edge\Extensions"
        ExtensionPaths   = @(
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge\Extensions",
            "HKLM:\SOFTWARE\Microsoft\Edge\Extensions"
        )
        UpdateUrl        = "https://edge.microsoft.com/extensionwebstorebase/v1/crx"
    }
}

# Function to get the next available name in a registry path
Function Get-NextAvailableName {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath
    )

    # Retrieve existing property names in the registry key if it exists
    $existingNames = @()
    if (Test-Path -Path $RegistryPath) {
        $itemProperties = Get-ItemProperty -Path $RegistryPath
        if ($itemProperties) {
            $existingNames = ($itemProperties | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
        }
    }

    # Find the next available numeric name
    $index = 1
    while ($existingNames -contains $index.ToString()) {
        $index++
    }
    return $index.ToString()
}

# Function to find an extension ID in the blocklist and return the property name if it exists
Function Find-Extension {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath,
        [Parameter(Mandatory = $true)]
        [string]$ExtensionID
    )

    if (Test-Path -Path $RegistryPath) {
        $existingProperties = Get-Item -Path $RegistryPath
        foreach ($property in $existingProperties.Property) {
            # Retrieve the value of each property directly
            $propertyValue = Get-ItemPropertyValue -Path $RegistryPath -Name $property
            if ($propertyValue -eq $ExtensionID) {
                return $property  # Return the property name if the extension exists
            }
        }
    }
    return $null  # Return null if the extension doesn't exist
}

# Function to remove a specific registry key
Function Remove-RegistryKey {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath
    )

    try {
        if (Test-Path -Path $RegistryPath) {
            Remove-Item -Path $RegistryPath -Force -ErrorAction Stop
            Write-Output "Successfully removed: $RegistryPath"
        } else {
            Write-Output "Registry path does not exist: $RegistryPath"
        }
    } catch {
        Write-Output "Error removing registry path: $RegistryPath - $_"
    }
}

# Function to install an extension using registry-based installation
Function Install-Extension {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Browser,
        [Parameter(Mandatory = $true)]
        [string]$ExtensionID,
        [string]$UpdateUrl  # Optional parameter for a custom update URL
    )

    # Retrieve the registry path object for the specified browser
    $registryPaths = $extensionRegistryPaths[$Browser]
    if (-not $registryPaths) {
        throw "Unsupported browser: $Browser"
    }

    # Set the update URL to the provided one or default to the browser's standard URL
    $updateUrlToUse = $UpdateUrl ? $UpdateUrl : $registryPaths.UpdateUrl

    # Install the extension in each registry path specified for the browser
    foreach ($path in $registryPaths.ExtensionPaths) {
        $extensionPath = Join-Path -Path $path -ChildPath $ExtensionID
        if (!(Test-Path -Path $extensionPath)) {
            New-Item -Path $extensionPath -Force | Out-Null
        }
        New-ItemProperty -Path $extensionPath -Name "update_url" -Value $updateUrlToUse -PropertyType String -Force | Out-Null
        Write-Output "Installed $Browser extension: $ExtensionID with update URL $updateUrlToUse"
    }
}

# Function to force-install an extension
Function Force-InstallExtension {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Browser,

        [Parameter(Mandatory = $true)]
        [string]$ExtensionID
    )

    # Retrieve the registry path object for the specified browser
    $registryPaths = $extensionRegistryPaths[$Browser]
    if (-not $registryPaths) {
        throw "Unsupported browser: $Browser"
    }

    # Set up the ForceInstall entry in the registry path
    $forceInstallPath = $registryPaths.ForceInstallPath
    if (!(Test-Path -Path $forceInstallPath)) {
        New-Item -Path $forceInstallPath -Force | Out-Null
    }

    # Use Get-NextAvailableName to find the next available index for installation entry
    $nextAvailableName = Get-NextAvailableName -RegistryPath $forceInstallPath
    New-ItemProperty -Path $forceInstallPath -Name $nextAvailableName -Value $ExtensionID -PropertyType String -Force | Out-Null

    # Message to confirm force-installation
    Write-Output "Force-installed $Browser extension: $ExtensionID under name $nextAvailableName"

    # Message to restart browser
    Write-Output "Please restart the browser to apply changes."
}

# Function to block an extension by adding it to the blocklist without duplicating entries
Function Block-Extension {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Browser,
        [Parameter(Mandatory = $true)]
        [string]$ExtensionID
    )

    # Retrieve the registry path object for the specified browser
    $registryPaths = $extensionRegistryPaths[$Browser]
    if (-not $registryPaths) {
        throw "Unsupported browser: $Browser"
    }

    # Ensure blocklist registry path exists
    $blocklistPath = $registryPaths.BlocklistPath
    if (!(Test-Path -Path $blocklistPath)) {
        New-Item -Path $blocklistPath -Force | Out-Null
    }

    # Use Find-Extension to check if the extension ID is already blocked
    $existingProperty = Find-Extension -RegistryPath $blocklistPath -ExtensionID $ExtensionID
    if ($existingProperty) {
        Write-Output "$Browser extension: $ExtensionID is already blocked under name $existingProperty"
        return
    }

    # Get the next available name and add the extension to the blocklist if not already present
    $nextAvailableName = Get-NextAvailableName -RegistryPath $blocklistPath
    New-ItemProperty -Path $blocklistPath -Name $nextAvailableName -Value $ExtensionID -PropertyType String -Force | Out-Null
    Write-Output "Blocked $Browser extension: $ExtensionID under name $nextAvailableName"
}

# Function to unblock an extension by removing all matching entries from the blocklist
Function Unblock-Extension {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Browser,
        [Parameter(Mandatory = $true)]
        [string]$ExtensionID
    )

    # Retrieve the registry path object for the specified browser
    $registryPaths = $extensionRegistryPaths[$Browser]
    if (-not $registryPaths) {
        throw "Unsupported browser: $Browser"
    }

    # Get the blocklist path for the specified browser
    $blocklistPath = $registryPaths.BlocklistPath
    if (Test-Path -Path $blocklistPath) {
        $removed = $false
        # Use Find-Extension to locate the extension property name, if it exists
        while ($property = Find-Extension -RegistryPath $blocklistPath -ExtensionID $ExtensionID) {
            Remove-ItemProperty -Path $blocklistPath -Name $property -Force
            Write-Output "Unblocked $Browser extension: $ExtensionID by removing name $property"
            $removed = $true
        }
        if (-not $removed) {
            Write-Output "Extension ID $ExtensionID not found in $Browser blocklist."
        }
    } else {
        Write-Output "Blocklist path does not exist for $Browser."
    }
}

# Function to remove an extension from all relevant registry paths
Function Remove-Extension {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Browser,
        [Parameter(Mandatory = $true)]
        [string]$ExtensionID
    )

    # Retrieve the registry path object for the specified browser
    $registryPaths = $extensionRegistryPaths[$Browser]
    if (-not $registryPaths) {
        throw "Unsupported browser: $Browser"
    }

    # Iterate over each extension path and attempt to remove the specified extension
    foreach ($path in $registryPaths.ExtensionPaths) {
        $extensionPath = Join-Path -Path $path -ChildPath $ExtensionID
        Remove-RegistryKey -RegistryPath $extensionPath
    }
}

# Function to remove a force-installed extension
Function Force-RemoveExtension {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Browser,

        [Parameter(Mandatory = $true)]
        [string]$ExtensionID
    )

    # Retrieve the registry path object for the specified browser
    $registryPaths = $extensionRegistryPaths[$Browser]
    if (-not $registryPaths) {
        throw "Unsupported browser: $Browser"
    }

    # Get the ForceInstall path for the specified browser
    $forceInstallPath = $registryPaths.ForceInstallPath
    if (Test-Path -Path $forceInstallPath) {
        $removed = $false
        # Iterate over each property to find and remove matching extension entries
        $existingProperties = Get-Item -Path $forceInstallPath
        foreach ($property in $existingProperties.Property) {
            # Retrieve the value of each property to check against ExtensionID
            $propertyValue = Get-ItemPropertyValue -Path $forceInstallPath -Name $property
            if ($propertyValue -eq $ExtensionID) {
                Remove-ItemProperty -Path $forceInstallPath -Name $property -Force
                Write-Output "Force-removed $Browser extension: $ExtensionID by removing name $property"
                $removed = $true
            }
        }
        if (-not $removed) {
            Write-Output "Extension ID $ExtensionID not found in $Browser ForceInstall path."
        }
    } else {
        Write-Output "ForceInstall path does not exist for $Browser."
    }

    # Message to restart browser
    Write-Output "Please restart the browser to apply changes."
}