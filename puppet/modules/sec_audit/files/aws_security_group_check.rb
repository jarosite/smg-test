#!/usr/bin/env ruby
# -*- mode: ruby -*-
# # vi: set ft=ruby :
#

#● ruby script should expect data from stdin. Use pipelines to feed json data into script.
#● accept accept one optional parameter ­­cron (use trollop gem if you wish)
#● report all security group / ports or port ranges sets that are accessible from public
#Internet (0.0.0.0/0)
#● report a list of sorted unique ip addresses or network ranges that have special
#access rights in security groups
#● if ­­cron parameter is used then instead of reports above just convert json into a
#grepable format. Each line should have security group name, access rule; one rule per line.

require "rubygems"
require "json"

def transform_sg_json_to_printable_view(security_groups_object)
	unic_ip = Hash.new
	security_groups_object['SecurityGroups'].each { |sg|
		sg['IpPermissions'].each{ |inbound_rule|
			inbound_rule['IpRanges'].each{ |ip|
				unic_ip[ip['CidrIp']] = [] unless unic_ip.has_key?(ip['CidrIp'])
				unic_ip[ip['CidrIp']] << {
					'GroupName' => sg['GroupName'],
					'IpProtocol' => inbound_rule['IpProtocol'],
					'PortRange' => inbound_rule['FromPort'] == inbound_rule['ToPort']? (inbound_rule['FromPort']) : ("#{inbound_rule['FromPort']} - #{inbound_rule['ToPort']}")
				}
			}
		} if sg.has_key?('IpPermissions')
	}
	unic_ip
end

WIDE_OPEN = '0.0.0.0/0'
unic_ip = transform_sg_json_to_printable_view( JSON.parse( STDIN.read ))
#	puts JSON.pretty_generate(unic_ip)
if ARGV.length == 1 and ARGV[0] == "--cron"
	puts unic_ip.map { |ip, rules| rules.map { |rule|  "%s | %s | %s | %s" %  [rule['GroupName'], ip, rule['IpProtocol'], rule['PortRange'] ]}}
elsif ARGV.length == 0
	puts "\nSecurity groups that are accessible from Internet"
	puts unic_ip[WIDE_OPEN].map {|rule| "%s > %s %s" % [rule['GroupName'], rule['IpProtocol'], rule['PortRange']] }

	puts "\nIP addresses with a special ACLs"
	puts unic_ip.keys
else
	#TODO Help there
	puts "\nUnknown arguments"
end



