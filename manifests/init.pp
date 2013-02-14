#
# class for installing and configuring tempest
# This manifest just sets up the basic config for
# tempest. After it is applied, the following still needs
# to be performed.
#  - ensure that openstack::auth is also applied
#  - bash /tmp/test_nova.sh (this will install an image)
#  - capture the image name of the created image with `glance index`
#  - fill in the XXXX in /var/lib/tempest/etc/tempest.conf with the image ID
#  - run `nosetests temptest`
#
class tempest(
  $identity_host        = 'localhost',
  $identity_port        = '35357',
  $identity_api_version = 'v2.0',
  # non admin user
  $username             = 'user1',
  $password             = 'user1_password',
  $tenant_name          = 'tenant1',
  # another non-admin user
  $alt_username         = 'user2',
  $alt_password         = 'user2_password',
  $alt_tenant_name      = 'tenant2',
  # image information
  $image_id             = 'XXXXXXX',#<%= image_id %>,
  $image_id_alt         = 'XXXXXXX',#<%= image_id_alt %>,
  $flavor_ref           = 1,
  $flavor_ref_alt       = 2,
  # the version of the openstack images api to use
  $image_api_version    = '1',
  $image_host           = 'localhost',
  $image_port           = '9292',

  # this should be the username of a user with administrative privileges
  $admin_username       = 'admin',
  $admin_password       = 'ChangeMe',
  $admin_tenant_name    = 'openstack',

  $git_protocol         = 'git',
  $revision             = 'master'
) {

  include git

  package { [
    'python-unittest2',
    'python-httplib2',
    'python-paramiko',
    'python-nose'
    ]:
    ensure => present,
  }

  vcsrepo { '/var/lib/tempest':
    ensure   => 'present',
    source   => "${git_protocol}://github.com/openstack/tempest.git",
    revision => $revision,
    provider => 'git',
    require  => Class['git'],
  }

  file { '/var/lib/tempest/etc/tempest.conf':
    content => template('tempest/tempest.conf.erb'),
    require => Vcsrepo['/var/lib/tempest'],
  }

  keystone_tenant { $tenant_name:
    ensure      => present,
    enabled     => 'True',
    description => 'admin tenant',
  }
  keystone_user { $username:
    ensure      => present,
    enabled     => 'True',
    tenant      => $tenant_name,
    password    => $password,
  }

  keystone_tenant { $alt_tenant_name:
    ensure      => present,
    enabled     => 'True',
    description => 'admin tenant',
  }
  keystone_user { $alt_username:
    ensure      => present,
    enabled     => 'True',
    tenant      => $alt_tenant_name,
    password    => $alt_password,
  }

}
