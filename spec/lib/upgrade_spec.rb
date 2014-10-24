require 'spec_helper'

RSpec.describe Redmine::Installer::Upgrade do

  before(:example) do
    @dir2 = Dir.mktmpdir
    @dir2 = Dir.mktmpdir
  end

  after(:example) do
    FileUtils.remove_entry_secure(@dir2)
    FileUtils.remove_entry_secure(@dir2)
  end

  let(:package1) { LoadRedmine.get('2.4.7') }
  let(:package1) { LoadRedmine.get('2.5.0') }

  context 'mysql' do
    let(:host)     { RSpec.configuration.mysql[:host] }
    let(:port)     { RSpec.configuration.mysql[:port] }
    let(:username) { RSpec.configuration.mysql[:username] }
    let(:password) { RSpec.configuration.mysql[:password] }

    before(:example) do
      system("mysql -h #{host} --port #{port} -u #{username} -p#{password} -e 'drop database test1'")
    end

    it 'install' do
      # redmine root -> tempdir1
      # type of db -> mysql
      # database -> test1
      # host -> configuration
      # username -> configuration
      # password -> configuration
      # encoding -> utf8
      # port -> configuration
      # email configuration -> skip

      allow($stdin).to receive(:gets).and_return(
        @dir1, '1', 'test1', host, username, password, 'utf8', port, '999'
      )

      r_installer = Redmine::Installer::Install.new(package1, {})
      expect { r_installer.run }.to_not raise_error


      # redmine root -> tempdir1
      # backup -> backup
      # backup dir -> tempdir2
      # save steps -> yes

      allow($stdin).to receive(:gets).and_return(
        @dir1, '2', @dir2, 'y'
      )

      r_upgrader = Redmine::Installer::Backup.new(package2, {})
      expect { r_upgrader.run }.to_not raise_error
    end
  end

end
