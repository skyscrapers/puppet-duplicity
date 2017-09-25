# duplicity

[![Puppet Forge](https://img.shields.io/puppetforge/v/tohuwabohu/duplicity.svg)](https://forge.puppetlabs.com/tohuwabohu/duplicity)
[![Build Status](https://travis-ci.org/skyscrapers/puppet-duplicity.svg?branch=master)](https://travis-ci.org/skyscrapers/puppet-duplicity)

## Overview

Configure [duply](http://duply.net/) on top of [duplicity](http://duplicity.nongnu.org/) to provide a profile-based,
easy to use backup and restore system.

## Usage

Install duplicity and duply with all default values.

```
class { 'duplicity':
  ensure => present,
}
```

Install a more recent version of duply from [the sourceforge project page](http://sourceforge.net/projects/ftplicity/)

```
class { 'duplicity':
  duply_package_provider => 'archive',
  duply_archive_version  => '1.9.1',
  duply_archive_md5sum   => 'd584940b9c740c81a2a081bc154084b9',
}
```

Specify the backup server to be used; see the duplicity documentation for more information about the available protocols.

```
class { 'duplicity':
  backup_target_url      => 'ftps://backup.example.com/',
  backup_target_username => 'username',
  backup_target_password => 'password',
}
```

In case you're using duply 1.10+ and a storage backend that requires additional environment variables to be set, use
the following pattern

```
class { 'duplicity':
  duply_environment => [
    "export AWS_ACCESS_KEY_ID='${my_access_key}'",
    "export AWS_SECRET_ACCESS_KEY='${my_secret_key}'",
  ],
}
```

This works on a profile-level as well.

Configure a simple backup profile that stops an application before the backup starts and starts it when complete.
It will run once a day, do incremental backups by default and create a full backup if the previous full backup
is older than 7 days. Duplicity will keep at most two full backups and purge older ones.

```
duplicity::profile { 'system':
  full_if_older_than  => '7D',
  max_full_backups    => 2,
  cron_hour           => '4',
  cron_minute         => '0',
  exec_before_content => '/bin/systemctl stop myapp',
  exec_after_content  => '/bin/systemctl start myapp',
}
```

Backup a file and restore it from a previous backup if it is not existing. Setting `ensure` to `backup` will only
backup the file but not restore it.

Note: a directory will only be restored if the directory is not existing - an empty directory is not replaced.

```
duplicity::file { '/path/to/file':
  ensure => present,
}
```

Backup a directory by using a specific backup profile and exclude a bunch of files.

```
$data_dir = '/var/lib/jira'

duplicity::file { $data_dir:
  profile => 'jira',
  exclude => [
    "${data_dir}/caches",
    "${data_dir}/tmp",
    "${data_dir}/plugins/.osgi-plugins/felix/felix-cache",
    "${data_dir}/plugins/.osgi-plugins/transformed-plugins",
  ],
}
```

Define a GnuPG key pair `BEEF1234` to be used to de/encrypt the backup on the node itself and configure the backup
profile to use it. The encrytion key `ALICE00001` is used to decrypt the backup on another node (e.g. the admin's
workstation).

```
duplicity::private_key { 'BEEF1234':
  content => hiera('duplicity::private_key::BEEF1234'),
}

duplicity::public_key { 'BEEF1234':
  content => template('path/to/BEEF1234.pub.asc.erb'),
}

class { 'duplicity':
  gpg_encryption_keys => ['ALICE00001', 'BEEF1234'],
  gpg_signing_key     => 'BEEF1234',
}
```

Or turn off the encryption of backups for a particular profile altogether:

```
duplicity::profile { 'system':
  gpg_encryption => false,
}
```

## Limitations

The module has been tested on the following operating systems. Testing and patches for other platforms are welcome.

* Debian 8.0 (Jessie)
* Debian 9.0 (Stretch)
* Ubuntu 14.04 (Trusty Tahr)
* Ubuntu 16.04 (Xenial Xerus)
* RHEL/Centos 6

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Development

This project uses rspec-puppet and beaker to ensure the module works as expected and to prevent regressions.

```
gem install bundler
bundle install --path vendor

bundle exec rake spec
bundle exec rake beaker
```
(note: see [Beaker - Supported ENV variables](https://github.com/puppetlabs/beaker-rspec/blob/master/README.md) for a
list of environment variables to control the default behaviour of Beaker)
