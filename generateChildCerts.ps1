#Written by Ioannis Pantelidis, ipantelidis@outlook.com
#PROD Root Cert
$root = Read-Host -Prompt 'Please enter the thumbprint of the Root Cert that is installed on your pc.'
$cert = Get-ChildItem -Path "Cert:\CurrentUser\My\$root"
#Today
$date_now = Get-Date
#3 years from now
$extended_date = $date_now.AddYears(3)
#current path location
$here = Get-Location

#GeneratePassword Function
Function New-Password {
 
    [cmdletbinding()]
 
    Param (
        [parameter()]
        [ValidateRange(1,128)]
        [Int]$PasswordLength = 15,
        [parameter()]
        [Int]$NumNonAlphaNumeric = 7
    )
 
    If ($NumNonAlphaNumeric -gt $PasswordLength) {
        Write-Warning ("NumNonAlphaNumeric ({0}) cannot be greater than the PasswordLength ({1})!" -f`
            $NumNonAlphaNumeric,$PasswordLength)
        Break
    }
 
    Add-Type -AssemblyName System.Web
    [System.Web.Security.Membership]::GeneratePassword($PasswordLength,$NumNonAlphaNumeric)
}
#end of GeneratePassword 

#Create here 50 temp folders (if not exist)
for($i = 1; $i -le 50; $i++) { 
#variable for check
$check = Test-Path -Path $here"\Reserve name_"$i
#If path exist
		if($check -ne $true) {
			md "Reserve name_$i"
			Write-Host "Reserve name_$i directory created"
		}
}
			
#Creation of the child cert, the export of the cert and the deletion from the local repository			
For ($i=1; $i -le 50; $i++){
		
			#Copy instructions and the client in every folder.
			Copy-Item $here"\Instructions.docx" -Destination $here"\Reserve name_"$i
			Copy-Item $here"\ProductionVNG.zip" -Destination $here"\Reserve name_"$i
			
			#Create new password through the function
			$password = New-Password -PasswordLength 18 -NumNonAlphaNumeric 4
			#Secure Password
			$SecurePassword = ConvertTo-SecureString -String $password -Force -AsPlainText
			
			#Go to the subdirectory
			Set-Location -Path $here"\Reserve name_"$i
			
			#And create a txt file that will contain the password
			Set-Content -Path $here"\Reserve name_"$i"\Password.txt" -Value $password -Force 
			
			#Generate Certificate
			$childCert = New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature `
			-Subject "CN=P2SChildCert" -KeyExportPolicy Exportable `
			-HashAlgorithm sha256 -KeyLength 2048 `
			-CertStoreLocation "Cert:\CurrentUser\My" `
			-Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") -Notafter $extended_date 
			
			#Thumbprint cert
			$thumbprint = $childCert.Thumbprint
			
			#Export the Child Certificate here
			Export-PfxCertificate -Cert Cert:\currentuser\My\$thumbprint -FilePath "AzureVPNCert_PROD_2021.pfx" -Password $SecurePassword -Verbose 
			
			#Erase Child Cert from the pc
			
			if(( $item = Get-ChildItem -Path Cert:\currentuser\My\$thumbprint ) -And ($thumbprint -ne $null ) ) {
					$item | Remove-Item 
			} else {
					Write-Host "Item does not exist."
			}	
}

#change directory 
Set-Location -Path $here

#Define the path for zip
$path = $here.path

#Get all directories
$source = Get-ChildItem -Path $path -Directory

#Add the zip module
Add-Type -assembly "system.io.compression.filesystem"

#For each directory 
Foreach ($s in $source){
  #Make a destination zipfile
  $destination = Join-path -path $path -ChildPath "$($s.name).zip"
  #Check if the zipfile already exist and remove the old one if exist
  If(Test-path $destination) {
  Write-Host "Removing the old zip file: $destination"
  Remove-item $destination
  }
  
  #Create the archive
  [io.compression.zipfile]::CreateFromDirectory($s.fullname, $destination)
 }

#Finally remove every temp subdirectory

Write-Host "Cleaning temp files..."
for($i = 1; $i -le 50; $i++) { 
#variable for check
$check = Test-Path -Path $here"\Reserve name_"$i
#If path exist
		if($check -eq $true) {
			
			Remove-Item -Path $here"\Reserve name_"$i -Recurse -Force -Confirm:$false
		}
}
Write-Host "Done"


