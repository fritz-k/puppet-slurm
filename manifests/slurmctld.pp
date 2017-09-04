################################################################################
# Time-stamp: <Mon 2017-09-04 21:25 svarrette>
#
# File::      <tt>slurmctld.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::slurmctld
#
# The main helper class specializing the main slurm class for setting up a
# Slurmctld daemon aka the slurm controller
#
# === Warnings
#
# /!\ Always respect the style guide available here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
class slurm::slurmctld inherits slurm
{
  case $::osfamily {
    'Redhat': { }
    default:  { fail("Module ${module_name} is not supported on ${::operatingsystem}") }
  }

  $dir_ensure = $slurm::ensure ? {
    'present' => 'directory',
    default   => $slurm::ensure
  }
  file { $slurm::params::slurmctld_libdir:
    ensure => $dir_ensure,
    owner  => $slurm::params::username,
    group  => $slurm::params::group,
    mode   => $slurm::params::configdir_mode,
    force  => true,
    before => File[$slurm::configdir],
  }

  include ::slurm::install
  include ::slurm::config
  Class['slurm::install'] -> Class['slurm::config']

  if $slurm::ensure == 'present' {
    File <| tag == 'slurm::configfile' |> {
      require => File[$slurm::configdir],
      notify  +> Service['slurmctld'],
    }
  }

  if $slurm::service_manage == true {

    service { 'slurmctld':
      ensure     => ($slurm::ensure == 'present'),
      enable     => ($slurm::ensure == 'present'),
      name       => $slurm::params::controller_servicename,
      pattern    => $slurm::params::controller_processname,
      hasrestart => $slurm::params::hasrestart,
      hasstatus  => $slurm::params::hasstatus,
    }

    # if $slurm::ensure == 'present' {
      #   Class['slurm::install'] ->
      #   Class['slurm::config'] ->
      #   Service['slurmctld']
      # }
    # else {
      #   Service['slurmctld'] ->
      #   Class['slurm::install'] ->
      #   Class['slurm::config']
      # }
  }

}
