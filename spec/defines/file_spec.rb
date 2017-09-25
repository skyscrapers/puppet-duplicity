require 'spec_helper'

describe 'duplicity::file' do
  let(:title) { '/path/to/file' }
  let(:include_fragment) { '/etc/duply/system/include/b4a91649090a2784056565363583d067' }
  let(:exclude_fragment) { '/etc/duply/system/exclude/b4a91649090a2784056565363583d067' }
  let(:restore_exec) { 'restore /path/to/file' }
  let(:pre_condition) { <<-EOS
      # declare profiles referenced later
      duplicity::profile { 'system': }

      class { 'duplicity': }
    EOS
  }

  describe 'by default' do
    let(:params) { {} }

    specify {
      should contain_concat__fragment(include_fragment).with(
        'content' => "+ /path/to/file"
      )
    }
    specify { should contain_exec(restore_exec).with_command(/system fetch "path\/to\/file" "\/path\/to\/file"$/) }
    specify { should contain_exec(restore_exec).with_creates('/path/to/file') }
  end

  describe 'with ensure absent' do
    let(:params) { {:ensure => 'absent'} }

    specify { should_not contain_concat__fragment(include_fragment) }
    specify { should_not contain_exec(restore_exec) }
  end

  describe 'with ensure backup' do
    let(:params) { {:ensure => 'backup'} }

    specify { should_not contain_exec(restore_exec) }
  end

  describe 'with invalid ensure' do
    let(:params) { {:ensure => 'foobar'} }

    specify do
      expect { should contain_concat__fragment(include_fragment) }.to raise_error(Puppet::Error, /ensure/)
    end
  end

  describe 'with invalid path' do
    let(:params) { {:path => 'relative/path'} }

    specify do
      expect { should contain_concat__fragment(include_fragment) }.to raise_error(Puppet::Error, /path/)
    end
  end

  describe 'with empty profile' do
    let(:params) { {:profile => ''} }

    specify do
      expect { should contain_concat__fragment(include_fragment) }.to raise_error(Puppet::Error, /profile/)
    end
  end

  describe 'with invalid profile' do
    let(:params) { {:profile => 'in val$d'} }

    specify do
      expect { should contain_concat__fragment(include_fragment) }.to raise_error(Puppet::Error, /profile/)
    end
  end

  describe 'with exclude => ["/a/b"]' do
    let(:params) { {:exclude => ['/a/b']} }

    specify { should contain_concat__fragment(exclude_fragment).with_content(/^\- \/a\/b$/) }
  end

  describe 'with exclude => ["/a", "/b"]' do
    let(:params) { {:exclude => ['/a', '/b']} }

    specify { should contain_concat__fragment(exclude_fragment).with_content(/^\- \/a$/) }
    specify { should contain_concat__fragment(exclude_fragment).with_content(/^\- \/b$/) }
  end

  describe 'with invalid exclude' do
    let(:params) { {:exclude => 'not-an-array'} }

    specify {
      expect { should contain_concat__fragment(exclude_fragment) }.to raise_error(Puppet::Error, /exclude/)
    }
  end

  describe 'with timeout => 60' do
    let(:params) { {:timeout => 60} }

    specify { should contain_exec(restore_exec).with_timeout(60) }
  end
end
