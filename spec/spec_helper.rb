require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.default_facts = {
    # concat
    :concat_basedir    => '/path/to/dir',
    :id                => 'deadbeef',
    :kernel            => 'deadbeef',
    :path              => '/usr/bin',

    # logrotate
    :lsbdistcodename   => 'Jessie',

    :operatingsystem   => 'Debian',
    :osfamily          => 'Debian',
    :lsbmajdistrelease => '8',
  }
end
