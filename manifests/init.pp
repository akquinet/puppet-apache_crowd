# Class: puppet-apache_crowd
#
# This module manages puppet-apache_crowd, so far only for RHEL environments.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class apache_crowd (
	$authnz_version = '2.0.1-1.el6.x86_64',
	$filter_release = '*.el6.*'	
){	
#	installation of 3rd party dependencies
	case $::operatingsystem {
		redhat,centos,oel : {
			$pkg_perl = 'mod_perl'
			$pkg_perl_soap = 'perl-SOAP-Lite'
			$pkg_perl_cache = 'perl-Cache-Cache'
			$pkg_perl_libwww = 'perl-libwww-perl'
			
			package { "$pkg_perl":
					ensure => present,
			}
			package { "$pkg_perl_soap":
					ensure => present,
			} 
			package { "$pkg_perl_cache":
					ensure => present,
			} 
			package { "$pkg_perl_libwww":
					ensure => present,
			}
			$pkg_dependencies = Package["$pkg_perl","$pkg_perl_soap","$pkg_perl_cache","$pkg_perl_libwww"]			
		}
		default : {
			fail("operating system currently not supported")		
		}
	}
	
	$cmdcat = "/bin/cat"
	$cmdecho = "/bin/echo"
	$cmdgrep = "/bin/grep"
	$cmdtest = "/usr/bin/test"
	$httpd_conf = "$apache::params::config_dir/conf/httpd.conf"
	
	pkgmngt::install {
		"mod_authnz_rpm" :
			download_url => "https://studio.plugins.atlassian.com/svn/CWDAPACHE/tags/2.0.1/packages/rhel6/mod_authnz_crowd-${authnz_version}.rpm",
			require => $pkg_dependencies,
			onlyif => "$cmdtest \"$($cmdcat $httpd_conf | $cmdgrep \"mod_authnz_crowd\")\" = \"\"",			
	} 
	
	$atlassian_rpms_zip='atlassian-RPMS.zip'
	
	pkgmngt::install {
		"atlassian_rpms" :
			download_url => "https://studio.plugins.atlassian.com/source/browse/~tarball=zip/CWDAPACHE/branches/1.x/RPMS/RPMS.zip",
			custom_install_selection => "$filter_release",
			require => $pkg_dependencies,
			onlyif => "/usr/bin/test \"$(/usr/bin/yum search perl-Atlassian-Crowd | $cmdgrep \"No Matches found\")\" != \"\"",
	}
		
}
