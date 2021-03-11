<h1>Azure Point to Site VPN – Add new root certificate and generate multiple child certificates </h1>
<p>I developed an automation script based on <a href="https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site">Microsoft documentation</a> and based on this <a href="https://www.digitaldarragh.com/2019/01/18/azure-point-to-site-vpn-add-or-replace-certificates">article </a>. The script was written in PowerShell and made my work life easier regarding of making VPN Child certificates for the users. </br> The script creates multiple temporary directories, on each directory a child certificate is created and is exported into a pfx format with an auto generated password saved on a txt file. </br>
The child certificates lasts 3 years but you can modify the script to last longer than 3 years. <br>
In addition this script copy-paste on each directory the Instructions.docx that you may want to provide to the user and the Azure VPN client (that you need to download it from your Azure portal). </br> Finally it archive all the directories indidual and cleaning the temporary directories. </p>

<h3>Instructions: </h3>

<ul>
  <li>First of all, create the root certificate on your computer that will expire in 3 years using the following powershell commands:</li>


```powershell
$date_now = Get-Date
$extended_date = $date_now.AddYears(3)
$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject “CN=P2SRootCert” -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation “Cert:\CurrentUser\My” -KeyUsageProperty Sign -KeyUsage CertSign -Notafter $extended_date
 ```
<li>Note the thumbprint of the root certificate, use the <a href="https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site"> Microsoft documentantion </a> to export the certificate and import it on Azure Portal.</li>

<li>Download the Azure VPN Client from Azure Portal.</li>
<li>Modify the script on your needs and execute it to generate multiple child certificates.</li>
</ul>
