require 'spec_helper_acceptance'

describe 'with profile and file' do
  let(:manifest) { <<-EOS
      class { 'duplicity':
        backup_target_url      => 'file:///tmp/duplicity/',
        backup_target_username => 'john',
        backup_target_password => 'doe',
        duply_environment      => [
          "export AWS_ACCESS_KEY_ID='dead'",
          "export AWS_SECRET_ACCESS_KEY='beef'",
        ],
      }

      duplicity::profile { 'system':
        gpg_encryption => false,
      }

      duplicity::file { '/etc/duply':
        ensure => backup,
      }
  EOS
  }

  specify 'should provision with no errors' do
    apply_manifest(manifest, :catch_failures => true)
  end

  specify 'should be idempotent' do
    apply_manifest(manifest, :catch_changes => true)
  end

  describe command('duply system status') do
    its(:exit_status) { should eq 0 }
  end

  describe command('duply system backup') do
    its(:exit_status) { should eq 0 }
  end

  describe file('/etc/duply/system/conf') do
    it { should contain "export AWS_ACCESS_KEY_ID='dead'" }
  end

  describe file('/etc/duply/system/conf') do
    it { should contain "export AWS_SECRET_ACCESS_KEY='beef'" }
  end
end
