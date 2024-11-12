[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto?frequency=one-time&sponsor=asheroto)
<a href="https://ko-fi.com/asheroto"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Ko-Fi Button" height="20px"></a>
<a href="https://www.buymeacoffee.com/asheroto"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=Manage-Browser-Extensions&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff)" height="40px"></a>

# Extension Management for Chrome and Edge

This script provides administrators with PowerShell functions to manage browser extensions in Chrome and Edge.

> [!NOTE]
> Firefox is not supported.

# Features

- **Install Extensions**: Adds specified extensions to the registry with an optional update URL, allowing installation in the browser.
- **Remove Specified Extensions**: Deletes a specified extension from the browser by removing associated registry entries.
- **Block Extensions**: Prevents installation of specified extensions by adding them to the registry blocklist.
- **Unblock Extensions**: Allows installation of specified extensions if previously blocked by removing them from the blocklist.
- **Force-Install Extensions**: Enforces installation of specified extensions by adding them to the ForceInstall policy list in the registry.
- **Remove Force-Installed Extensions**: Removes specified extensions from the ForceInstall policy list, undoing enforced installations.

# Requirements

- **Administrator Privileges**: This script modifies registry entries under `HKLM` (HKEY_LOCAL_MACHINE), which requires administrative rights.

# Installation

Clone or download this repository to your local machine:

```bash
git clone https://github.com/asheroto/Manage-Browser-Extensions
cd Manage-Browser-Extensions
```

or save the raw script file.

# Usage

Import the functions

```powershell
Import-Module .\Manage-Browser-Extensions.ps1 -Force
```

You can then call the functions provided in the script as needed.

## Functions

### Install-Extension

Installs a specified extension in Edge by setting the update URL in the registry.

**Syntax**:
```powershell
Install-Extension -Browser "Edge" -ExtensionID "elhekieabhbkpmcefcoobjddigjcaadp"
```

**Example**:
```powershell
Install-Extension -Browser "Edge" -ExtensionID "elhekieabhbkpmcefcoobjddigjcaadp"
```

### Remove-Extension

Removes a specified extension from Chrome by deleting associated registry entries.

**Syntax**:
```powershell
Remove-Extension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
```

**Example**:
```powershell
Remove-Extension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
```

### Force-InstallExtension

Force-installs an extension in Chrome, adding it to the ForceInstall policy list.

**Syntax**:
```powershell
Force-InstallExtension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
```

**Example**:
```powershell
Force-InstallExtension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
```

### Force-RemoveExtension

Removes a force-installed extension from Chrome’s ForceInstall list.

**Syntax**:
```powershell
Force-RemoveExtension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
```

**Example**:
```powershell
Force-RemoveExtension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
```

### Block-Extension

Adds a specified extension to Chrome’s blocklist, preventing installation.

**Syntax**:
```powershell
Block-Extension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
```

**Example**:
```powershell
Block-Extension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
```

### Unblock-Extension

Removes a specified extension from Edge’s blocklist, allowing installation if it was previously blocked.

**Syntax**:
```powershell
Unblock-Extension -Browser "Edge" -ExtensionID "elhekieabhbkpmcefcoobjddigjcaadp"
```

**Example**:
```powershell
Unblock-Extension -Browser "Edge" -ExtensionID "elhekieabhbkpmcefcoobjddigjcaadp"
```

# Important Notes

- **No Restart Required**: Changes take effect immediately without requiring a browser or system restart. However, users may need to refresh the browser for the changes to fully apply.
- **Supported Browsers**: This script only manages extensions for Chrome and Edge.

# License

This project is licensed under the MIT License.

# Contributing

Contributions are welcome! Please submit a pull request or open an issue for any suggestions or improvements.