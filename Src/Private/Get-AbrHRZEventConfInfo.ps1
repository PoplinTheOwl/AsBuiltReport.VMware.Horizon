function Get-AbrHRZEventConfInfo {
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
        Write-PScriboMessage "EventDatabase InfoLevel set at $($InfoLevel.Settings.EventConfiguration.EventDatabase)."
        Write-PscriboMessage "Collecting Event Configuration information."
    }

    process {
        try {
            if ($EventDataBases -or $Syslog) {
                if ($InfoLevel.Settings.EventConfiguration.PSObject.Properties.Value -ne 0) {
                    section -Style Heading4 "Event Configuration" {
                        if ($InfoLevel.Settings.EventConfiguration.EventDatabase -ge 1 -and $EventDataBases.EventDatabaseSet) {
                            try {
                                section -Style Heading5 "Event Database" {
                                    $OutObj = @()
                                    foreach ($EventDataBase in $EventDataBases) {
                                        Write-PscriboMessage "Discovered Event Database Information."
                                        $inObj = [ordered] @{
                                            'Server' = $EventDataBase.database.Server
                                            'Type' = $EventDataBase.database.Type
                                            'Port' = $EventDataBase.database.Port
                                            'Name' = $EventDataBase.database.Name
                                            'User Name' = $EventDataBase.database.UserName
                                            'Table Prefix' = $EventDataBase.database.TablePrefix
                                            'Show Events for' = $EventDataBase.Settings.ShowEventsForTime
                                            'Classify Events as New for' = "$($EventDataBase.Settings.ClassifyEventsAsNewForDays) Days"
                                            'Timing Profiler Events' = "$($EventDataBase.Settings.TimingProfilerDataLongevity) Days"
                                        }

                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                    }

                                    $TableParams = @{
                                        Name = "Event Database - $($HVEnvironment)"
                                        List = $true
                                        ColumnWidths = 50, 50
                                    }

                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }
                                    $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                                }
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }
                        if ($InfoLevel.Settings.EventConfiguration.Syslog -ge 1 -and $Syslog.UdpData.Enabled) {
                            try {
                                section -Style Heading5 "Syslog" {
                                    $OutObj = @()
                                    foreach ($Logging in $Syslog) {
                                        Write-PscriboMessage "Discovered Syslog Information."
                                        $inObj = [ordered] @{
                                            'Server' = $Logging.UdpData.NetworkAddresses.split(':')[0]
                                            'Port' = $Logging.UdpData.NetworkAddresses.split(':')[1]
                                        }

                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                    }

                                    $TableParams = @{
                                        Name = "Syslog - $($HVEnvironment)"
                                        List = $false
                                        ColumnWidths = 50, 50
                                    }

                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }
                                    $OutObj | Sort-Object -Property 'Server' | Table @TableParams
                                }
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }
                        if ($InfoLevel.Settings.EventConfiguration.EventstoFileSystem -ge 1 -and ($Syslog.FileData.Enabled -or $Syslog.FileData.EnabledOnError)) {
                            try {
                                section -Style Heading5 "Events to File System" {
                                    $OutObj = @()
                                    foreach ($Logging in $Syslog) {
                                        Write-PscriboMessage "Discovered Events to File System Information."
                                        $inObj = [ordered] @{
                                            'Path' = $Logging.FileData.UncPath
                                            'UserName' = $Logging.FileData.UncUserName
                                            'Domain' = $Logging.FileData.UncDomain
                                        }

                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                    }

                                    $TableParams = @{
                                        Name = "Events to File System - $($HVEnvironment)"
                                        List = $true
                                        ColumnWidths = 50, 50
                                    }

                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }
                                    $OutObj | Sort-Object -Property 'Server' | Table @TableParams
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
    end {}
}