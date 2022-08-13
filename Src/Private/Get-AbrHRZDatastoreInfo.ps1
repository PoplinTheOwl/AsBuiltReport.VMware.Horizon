function Get-AbrHRZDatastoreInfo {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        0.2.0
        Author:         Chris Hildebrandt, Karl Newick
        Twitter:        @childebrandt42, @karlnewick
        Editor:         Jonathan Colon, @jcolonfzenpr
        Twitter:        @asbuiltreport
        Github:         AsBuiltReport
        Credits:        Iain Brighton (@iainbrighton) - PScribo module


    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon
    #>

    [CmdletBinding()]
    param (
    )

    begin {
        Write-PScriboMessage "Datastore InfoLevel set at $($InfoLevel.Settings.Servers.vCenterServers.DataStores)."
        Write-PscriboMessage "Collecting DataStores information."
    }

    process {
        try {
            if ($vCenterHealth) {
                if ($InfoLevel.Settings.Servers.vCenterServers.DataStores -ge 1) {
                    section -Style Heading4 "Datastore Summary" {
                        $OutObj = @()
                        $Datastores = $vCenterHealth.datastoredata
                        foreach ($DataStore in $Datastores) {
                            try {
                                Write-PscriboMessage "Discovered Datastore Information from $($DataStore.name)."
                                $inObj = [ordered] @{
                                    'Name' = $DataStore.name
                                    'Accessible' = $DataStore.Accessible
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        if ($HealthCheck.DataStores.Status) {
                            $OutObj | Where-Object { $_.'Accessible' -eq 'No'} | Set-Style -Style Warning
                        }

                        $TableParams = @{
                            Name = "Datastore Summary - $($HVEnvironment)"
                            List = $false
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                        try {
                            if ($InfoLevel.Settings.Servers.vCenterServers.DataStores -ge 2) {
                                section -Style Heading5 "Datastore Detailed Information" {
                                    foreach ($DataStore in $Datastores) {
                                        if ($DataStore) {
                                            try {
                                                section -Style Heading6 "$($DataStore.Name)" {
                                                    $OutObj = @()
                                                    Write-PscriboMessage "Discovered Datastore Information from $($DataStore.Name)."
                                                    $inObj = [ordered] @{
                                                        'Path' = $DataStore.Path
                                                        'Type' = $DataStore.DataStoreType
                                                        'Capacity' = "$([math]::round($DataStore.CapacityMB / 1MB))GB"
                                                        'Free Space' = "$([math]::round($DataStore.FreeSpaceMB / 1MB))GB"
                                                        'Accessible' = $DataStore.Accessible
                                                    }

                                                    $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                    if ($HealthCheck.DataStores.Status) {
                                                        $OutObj | Where-Object { $_.'Accessible' -eq 'No'} | Set-Style -Style Warning
                                                    }

                                                    $TableParams = @{
                                                        Name = "Datastore Details - $($DataStore.Name)"
                                                        List = $true
                                                        ColumnWidths = 50, 50
                                                    }

                                                    if ($Report.ShowTableCaptions) {
                                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                                    }
                                                    $OutObj | Table @TableParams
                                                }
                                            }
                                            catch {
                                                Write-PscriboMessage -IsWarning $_.Exception.Message
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        catch {
                            Write-PscriboMessage -IsWarning $_.Exception.Message
                        }
                    }
                }
            }
        }
        catch {
            Write-PscriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}