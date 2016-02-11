# Class: sec_audit
# ===========================
#
# Full description of class sec_audit here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `srcfile`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'sec_audit':
#      srcfile => '/opt/data/testsecgroups.txt',
#    }
#
# Authors
# -------
#
# Aleksey Savitskiy <jarosite@gmail.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class sec_audit(
	$srcfile = '/opt/data/testsecgroups.txt',
	$base_dir = '/home/ec2-user/sec_audit'
	){
	
	$script_dir = "${base_dir}/bin"
	$data_dir = "${base_dir}/data"
	#TODO move me to /var/log/sec_audit and add logrotate
	$log_dir = "${base_dir}/log"

  	cron { 'docker_registry_auth':
    	command => "/bin/bash -l -c 'cat ${srcfile} | $script_dir/aws_security_group_check.rb --cron | $script_dir/check_if_sg_changed.sh'",
    	hour    => '*/1',
    	minute  => 0,
    	require => File['aws_security_group_check','check_if_sg_changed']
  	}

  	file { [$base_dir, $log_dir, $script_dir, $data_dir ]:
  		ensure => directory,
  		mode   => '0755',
  	}
  	#TODO setup ruby
  	file { 'aws_security_group_check': 
		path => "$script_dir/aws_security_group_check.rb",
		ensure => file,
		mode => '0744',
		source => "puppet:///modules/${module_name}/aws_security_group_check.rb"
	}

	file { 'check_if_sg_changed': 
		path => "$script_dir/check_if_sg_changed.sh",
		ensure => file,
		mode => '0744',
		source => "puppet:///modules/${module_name}/check_if_sg_changed.sh"
	}


}
