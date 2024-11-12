[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto?frequency=one-time&sponsor=asheroto)
<a href="https://ko-fi.com/asheroto"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Ko-Fi Button" height="20px"></a>
<a href="https://www.buymeacoffee.com/asheroto"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=Manage-Browser-Extensions&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff)" height="40px"></a>

# Extension Management for Chrome and Edge

This script provides administrators with PowerShell functions to manage browser extensions in Chrome and Edge. Several other Chromium-based browsers honor the Chrome registry keys for extensions.

> [!NOTE]
> Firefox is not supported.

# Features

- **Install Extensions**: Adds specified extensions to the registry with an optional update URL, allowing installation in the browser.
- **Remove Specified Extensions**: Deletes a specified extension from the browser by removing associated registry entries.
- **Force-Install Extensions**: Enforces installation of specified extensions by adding them to the ForceInstall policy list in the registry.
- **Remove Force-Installed Extensions**: Removes specified extensions from the ForceInstall policy list, undoing enforced installations.
- **Block Extensions**: Prevents installation of specified extensions by adding them to the registry blocklist.
- **Unblock Extensions**: Allows installation of specified extensions if previously blocked by removing them from the blocklist.

# How it Works

These functions make use of Windows registry keys for extension management. No files are modified.

# Requirements

- **Administrator Privileges**: This script modifies registry entries under `HKLM` (HKEY_LOCAL_MACHINE), which requires administrative rights.

# Installation

Clone or download this repository to your local machine:

```bash
git clone https://github.com/asheroto/Manage-Browser-Extensions
cd Manage-Browser-Extensions
```

or save the raw script file.

To load the functions in this script, use **dot-sourcing** instead of `Import-Module`. This approach will ensure all variables and functions are accessible in the current PowerShell session.

# Usage

Dot-source the functions:

```powershell
. .\Manage-Browser-Extensions.ps1
```

This command loads the script and makes all functions available for use in the current session.

You can then call the functions provided in the script as needed.

## Parameters

| Parameter      | Required | Description                                                                    |
| -------------- | -------- | ------------------------------------------------------------------------------ |
| `-Browser`     | Yes      | Specifies the browser to apply the action to (e.g., "Chrome" or "Edge").       |
| `-ExtensionID` | Yes      | The unique ID of the extension to manage (install, block, unblock, or remove). |
| `-UpdateUrl`   | No       | `Install-Extension` **only**: URL for the extension's update manifest.         |

## Commands

| Command                  | Description                                                                           | Parameters                               |
| ------------------------ | ------------------------------------------------------------------------------------- | ---------------------------------------- |
| `Install-Extension`      | Installs an extension with an optional update URL.                                    | `-Browser`, `-ExtensionID`, `-UpdateUrl` |
| `Remove-Extension`       | Removes a specified extension from the browser.                                       | `-Browser`, `-ExtensionID`               |
| `Force-InstallExtension` | Forces the installation of an extension. Requires a browser restart to apply changes. | `-Browser`, `-ExtensionID`               |
| `Force-RemoveExtension`  | Removes a force-installed extension. Requires a browser restart to apply changes..    | `-Browser`, `-ExtensionID`               |
| `Block-Extension`        | Blocks a specified extension to prevent installation.                                 | `-Browser`, `-ExtensionID`               |
| `Unblock-Extension`      | Unblocks a specified extension to allow installation.                                 | `-Browser`, `-ExtensionID`               |

## Examples

**Install an extension in Chrome with a default update URL**:

```powershell
Install-Extension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
```

---

**Remove an extension from Edge**:

```powershell
Remove-Extension -Browser "Edge" -ExtensionID "elhekieabhbkpmcefcoobjddigjcaadp"
```

---

**Force-install an extension in Chrome**:

```powershell
Force-InstallExtension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
```

---

**Remove a force-installed extension from Edge**:

```powershell
Force-RemoveExtension -Browser "Edge" -ExtensionID "elhekieabhbkpmcefcoobjddigjcaadp"
```

---

**Block an extension in Chrome**:

```powershell
Block-Extension -Browser "Chrome" -ExtensionID "efaidnbmnnnibpcajpcglclefindmkaj"
```

---

**Unblock an extension in Edge**:

```powershell
Unblock-Extension -Browser "Edge" -ExtensionID "elhekieabhbkpmcefcoobjddigjcaadp"
```