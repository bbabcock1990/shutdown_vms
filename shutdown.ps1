<#
.SYNOPSIS
    Automated process of stopping all virtual machines after business-hours.
.DESCRIPTION
    This script is intended to automatically stop all virtual machines after business-hours that contain
    the tag "Shutdown" with value set to "yes/Yes". The script pulls all virtual machines from the Azure Subscription listed
    and runs the Stop-AzVM command to shut the virtual machine down. This runbook is triggered 
    via a Azure Automation running on a schedule.
    
.NOTES
    Script is offered as-is with no warranty, expressed or implied.
    Test it before you trust it
    Author      : Brandon Babcock
    Website     : https://www.linkedin.com/in/brandonbabcock1990/
    Version     : 1.0.0.0 Initial Build
#>

########## Script Execution ##########
workflow test-workflow
{
    #Subscription ID Pulled From Runbook Variables
    $azureSubId = Get-AutomationVariable -Name 'c1-internal-lab-subscription-id'

    # Log into Azure
    try {
        Connect-AzAccount -Identity
        $AzureContext = Set-AzContext -SubscriptionId $azureSubId
        Write-Output "Login Successful!"
    }
    catch {
        $ErrorMessage = $_.Exception.message
        Write-Error ("Error logging into Azure: " + $ErrorMessage)
    }

    # Shutdown VMs With "Shutdown" tag set to "Yes/yes"
    Write-Output "Grabbing All VMs with 'Shutdown' tag set to 'Yes/yes'"
    $vms = Get-AzVM | Where {$_.Tags.keys -contains "Shutdown" -and $_.Tags.Values -contains "Yes"}

    try{
    foreach -parallel ($vm in $vms) {
        Stop-AzVM -ErrorAction Stop -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Force -AsJob
        Write-Output $vm.name
        Write-Output "Shutdown Successful"
    }
    }
    catch{
        $ErrorMessage = $_.Exception.message
        Write-Output "Error Shutting Down VMs: $ErrorMessage"
    }
}
