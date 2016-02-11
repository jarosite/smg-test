# smg-test


example of setup
>> puppet apply --modulepath=puppet/modules -e "class { 'sec_audit': srcfile => '/opt/data/testsecgroups.txt', base_dir => '$HOME/sec_audit'}"