Connect-NsxtServer -Server <NSX-T FQDN/IP> -User <Username> -Password <Password>

##Create a NSGroup based on a Security Tag
#Variables
$nsgroupname = "NS-Test"
$nstagname = "ST-Test"
#Create NSGroup
$nsgroupsvc = Get-NsxtService -Name com.vmware.nsx.ns_groups
$nsgroupspec = $nsgroupsvc.Help.create.ns_group.Create()
$nsgroupmemberspec = $nsgroupsvc.Help.create.ns_group.membership_criteria.Element.NS_group_tag_expression.create()
$nsgroupspec.display_name = $nsgroupname
$nsgroupmemberspec.tag_op = "EQUALS"
$nsgroupmemberspec.tag = $nstagname
$nsgroupmemberspec.target_type = "VirtualMachine"
$nsgroupspec.membership_criteria.Add($nsgroupmemberspec)
$nsgroupsvc.create($nsgroupspec)

##Delete a NSGroup
#Variables
$deletensgroupname = "NS-Test"
#Delete NSGroup
$nsgroupsvc = Get-NsxtService -Name com.vmware.nsx.ns_groups
$nsgroups = $nsgroupsvc.list()
$nsgroup = $nsgroups.results | Where-Object {$_.display_name -eq $deletensgroupname}
$nsgroupsvc.delete($nsgroup.id)

##List all NSGroups
#List all NSGroups
$nsgroupsvc = Get-NsxtService -Name com.vmware.nsx.ns_groups
$nsgroups = $nsgroupsvc.list()
$nsgroups.results | Format-Table -Autosize -Property id, display_name, members

###DFW Sections###

##Search for DFW Section
#Variables
$fwsectionname = "3 Tier-App" 
#Search for DFW Section
$fwsectsvc = Get-NsxtService -Name com.vmware.nsx.firewall.sections
$fwsections = $fwsectsvc.list()
$fwsection = $fwsections.results | Where-Object {$_.display_name -eq $fwsectionname}

##Create Firewall Rule in DFW Section
#Variables
$fwrulename = "Test Rule"
$fwruleaction = "ALLOW"
#Create Firewall Rule in DFW Section
$fwrulesvc = Get-NsxtService -Name com.vmware.nsx.firewall.sections.rules
$fwrulespec = $fwrulesvc.Help.create.firewall_rule.Create()
$fwrulespec.display_name = $fwrulename
$fwrulespec.action = $fwruleaction
$fwrulespec.logged = $true
$fwrulespec.revision = $fwsection.revision
$fwrule = $fwrulesvc.create($fwsection.id, $fwrulespec)

##Create DFW Section
#Variables
$fwsectname = "New Section"
#Create DFW Section
$fwsectspec = $fwsectsvc.Help.create.firewall_section.Create()
$fwsectspec.section_type = "LAYER3"
$fwsectspec.display_name = $fwsectname
$fwsectspec.stateful = $true
$fwsection = $fwsectsvc.create($fwsectspec, $fwsection.id, "insert_after")

###IP Sets###

##Create IP Set
#Variables
$ipsetname = "IP-Google"
$ipsetips = "8.8.8.8,8.8.4.4"
#Create IP Set
$ipsetsvc = Get-NsxtService -Name com.vmware.nsx.ip_sets
$ipsetspec = $ipsetsvc.Help.create.ip_set.Create()
$ipsetspec.ip_addresses = New-Object System.Collections.Generic.List[string]
$ipsetspec.display_name = $ipsetname
$ipsetips.Split(",") | ForEach { $ipsetspec.ip_addresses.Add($_) }
$ipsetsvc.create($ipsetspec)

##Delete IP Set
#Variables
$ipsetname = "IP-Google"
#Delete IP Set
$ipsets = $ipsetsvc.list()
$ipsetid = $ipsets.results | Where-Object {$_.display_name -eq $ipsetname}
$ipsetsvc.delete($ipsetid.id)

##List all IP Sets
#List all IP Sets
$ippoolsvc = Get-NsxtService -Name com.vmware.nsx.pools.ip_pools
$ippoolsvc.list().results | Format-Table -Autosize -Property id, display_name,@{Name="subnets";Expression={$_.subnets.cidr}}

### NS Services ###

##Create NS Service
#Variables
$servicename = "NSS-80-TCP" 
$serviceport = "80"
$serviceprot = "TCP"
#Create NS Service
$servicesvc = Get-NsxtService -Name com.vmware.nsx.ns_services
$servicespec = $servicesvc.Help.create.ns_service.Create()
$servicespec.display_name = $servicename
$servicedetailspec = $servicesvc.Help.create.ns_service.nsservice_element.l4_port_set_NS_service.Create()
$servicedetailspec.destination_ports = New-Object System.Collections.Generic.List[string]
$servicedetailspec.destination_ports.add($serviceport)
$servicedetailspec.l4_protocol = $serviceprot
$servicedetailspec.resource_type = "L4PortSetNSService"
$servicespec.nsservice_element = $servicedetailspec
$servicesvc.create($servicespec)

##Delete NS Service
#Variables
$servicename = "NSS-80-TCP"
#Delete Service
$servicesvc = Get-NsxtService -Name com.vmware.nsx.ns_services
$service = $services.results | Where-Object {$_.display_name -eq $servicename}
$servicesvc.delete($service.id)

##List all NS Services
#List NS Services
$servicesvc = Get-NsxtService -Name com.vmware.nsx.ns_services
$services = $servicesvc.list()
$services.results | Where-Object {$_.nsservice_element.l4_protocol -ne $null} | Format-Table -Autosize -Property id, display_name,@{Name="l4_protocol";Expression={$_.nsservice_element.l4_protocol}},@{Name="destination_ports";Expression={$_.nsservice_element.destination_ports}}

### Logical Switches ###

## Create Logical Switch
#Variables
$tzoneoverlayname = "TZ-Overlay"
$logswitchname = "PowerCLI Created LS"
#Get Transport Zone 
$tzonesvc = Get-NsxtService -Name com.vmware.nsx.transport_zones
$tzones = $tzonesvc.list()
$tzoneoverlay = $tzones.results | Where-Object {$_.display_name -eq $tzoneoverlayname}
#Create Logical Switch
$logswitchsvc = Get-NsxtService -Name com.vmware.nsx.logical_switches 
$logswitchspec = $logswitchsvc.Help.create.logical_switch.Create()
$logswitchspec.admin_state = "UP"
$logswitchspec.display_name = $logswitchname
$logswitchspec.replication_mode = "MTEP"
$logswitchspec.transport_zone_id = $tzoneoverlay.id
$logswitchsvc.create($logswitchspec)

## Delete Logical Switch
$logswitchname = "PowerCLI Created LS"
#Delete Logical Switch
$logswitchsvc = Get-NsxtService -Name com.vmware.nsx.logical_switches 
$logswitches = $logswitchsvc.list().results
$logswitch = $logswitches | Where-Object {$_.display_name -eq $logswitchname}
$logswitchsvc.delete($logswitch.id)

### Fabric ###

## Update vCenter Compute Manager Credentials
#Variables
$compmanagerusername = "administrator@vsphere.local"
$compmanagerpassword = "VMware1!"
$compmanagername = "<vCenter FQDN / IP>"
#Update vCenter Credentials
$compmanagersvc = Get-NsxtService -Name com.vmware.nsx.fabric.compute_managers
$compmanagers = $compmanagersvc.list()
$compmanager = $compmanagers.results | Where-Object {$_.server -eq $compmanagername} 
$compmanagerspec = $compmanagersvc.help.update.compute_manager.Create()
$compmanagerspec.server = $compmanager.server
$compmanagerspec.origin_type = $compmanager.origin_type
$compmanagerspec.revision = $compmanager.revision
$compmanagercredspec = $compmanagersvc.Help.update.compute_manager.credential.username_password_login_credential.Create()
$compmanagercredspec.username = $compmanagerusername
$compmanagercredspec.password = $compmanagerpassword
$compmanagercredspec.thumbprint = $compmanager.credential.thumbprint
$compmanagercredspec.credential_type = "UsernamePasswordLoginCredential"
$compmanagerspec.credential = $compmanagercredspec
$compmanagersvc.update($compmanager.id, $compmanagerspec)

### I was finally able to do a simple update:

Connect-NsxtServer virttest.local
$ipsetsvc = Get-NsxtService -Name com.vmware.nsx.ip_sets
$ipset_guid = $ipsetsvc.list().results | Where-Object -Property display_name -eq ‘mydisplayname’
$ipsetspec = $ipsetsvc.Help.create.ip_set.Create()
$ipsetips = “8.8.8.8,8.8.4.4”
$ipsetspec.display_name = “theupdatedname”
$ipsetspec.revision = $ipset_guid.revision #This Line was important and wouldnt update without it
$ipsetips.Split(“,”) | ForEach { $ipsetspec.ip_addresses.Add($_) }
$ipsetsvc.update($ipset_guid.id, $ipsetspec)

### Key seemed to be the revision variable.