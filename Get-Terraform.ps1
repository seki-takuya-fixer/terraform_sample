$terraformZip = [System.Uri]'https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_windows_amd64.zip'
$fileName = $terraformZip.Segments | Select-Object -Last 1
Invoke-RestMethod -Method Get -Uri $terraformZip -OutFile $fileName
$file = Get-Item -Path $fileName
Expand-Archive -Path $file -DestinationPath $file.BaseName
