# Input bindings are passed in via param block.
param($Timer)
 
# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()
 
# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}
 
# Authenticate with Azure using Managed Identity
Connect-AzAccount -Identity -ErrorAction Stop
 
# Get all VMs in the subscription tied to the Function App
$vmList = Get-AzVM
 
foreach ($vm in $vmList) {
    #Get name of VM
    $vmName = $vm.Name
 
    #Get Resource Group of VM
    $vmResourceGroupName = $vm.ResourceGroupName
   
    $powerState = (Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status).Statuses.Code
   
    Write-Output "VM: $vmName - Power State: $powerState"
   
    if ($powerState -eq "PowerState/running") {
        Write-Output "VM $vmName is running. Initiating deallocation..."
        Stop-AzVM -ResourceGroupName $vmResourceGroupName -Name $vmName -Force
        Write-Output "VM $vmName has been successfully deallocated."
    } elseif ($powerState -eq "PowerState/stopped") {
        Write-Output "VM $vmName is stopped. Initiating deallocation..."
        Stop-AzVM -ResourceGroupName $vmResourceGroupName -Name $vmName -Force
        Write-Output "VM $vmName has been successfully deallocated."
    } elseif ($powerState -eq "PowerState/deallocated") {
        Write-Output "VM $vmName is already deallocated. No action required."
    } else {
        Write-Output "VM $vmName is in state: $powerState. No action taken."
    }
}
