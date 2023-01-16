# Require 25 min to complete
set-executionpolicy unrestricted
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco feature enable -n=allowGlobalConfirmation
choco install googlechrome
choco install notepadplusplus.install
choco install netfx-4.8-devpack
choco install sql-server-express
choco install sql-server-management-studio
choco install visualstudio2019professional
choco install nodejs --version=10.1.0
choco install vscode
choco install javaruntime
Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2 -InstallationPolicy Trusted
Install-Module -Name SitecoreInstallFramework -RequiredVersion 2.3.0
Import-Module -Name SitecoreInstallFramework -Force -RequiredVersion 2.3.0
choco feature disable -n=allowGlobalConfirmation