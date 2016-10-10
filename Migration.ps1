Select-AzureSubscription "Desarrollo"

$servicename = "dev-migration"
$vmname = "dev-migration01"

Get-AzureVM -ServiceName $servicename -Name $vmname | Stop-AzureVM

# Source Storage Account Information #
$disk = Get-AzureDisk | Where-Object { $_.AttachedTo.RoleName -eq $vmname }
$mediaLink = $disk.MediaLink

$sourceStorageAccountName = $mediaLink.Host.Split('.')[0]
$blobName = $disk.MediaLink.Segments | Where-Object { $_ -like "*.vhd" }
$sourceKey = (Get-AzureStorageKey -StorageAccountName $sourceStorageAccountName).Primary
$sourceContext = New-AzureStorageContext -StorageAccountName $sourceStorageAccountName -StorageAccountKey $sourceKey
$sourceContainer = "vhds"

# Write-Host "VHD:" $blobName #
# Write-Host "StorageAccount:" $sourceStorageAccountName #

# Destiantion Storage Account Information #
$destinationStorageAccountName = "devmigration001"
$destinationKey = (Get-AzureStorageKey -StorageAccountName $destinationStorageAccountName).Primary
$destinationContext = New-AzureStorageContext -StorageAccountName $destinationStorageAccountName -StorageAccountKey $destinationKey
$destinationContainer = "vhds"
# Create the destination container if you dont have it #
# New-AzureStorageContainer -Name $destinationContainer -Context $destinationContext



# Copy the blob # 
$blobCopy = Start-AzureStorageBlobCopy -DestContainer $destinationContainer -DestContext $destinationContext -SrcBlob $blobName -Context $sourceContext -SrcContainer $sourceContainer

while(($blobCopy | Get-AzureStorageBlobCopyState).Status -eq "Pending")
{
    Start-Sleep -s 30
    $blobCopy | Get-AzureStorageBlobCopyState
}