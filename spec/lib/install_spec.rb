require 'spec_helper'

RSpec.describe Redmine::Installer::Install do

  before(:example) do
    @dir = Dir.mktmpdir
  end

  after(:example) do
    FileUtils.remove_entry_secure(@dir)
  end

  let(:package1) { LoadRedmine.get('2.4.7') }

  context 'mysql' do
    let(:host)     { RSpec.configuration.mysql[:host] }
    let(:port)     { RSpec.configuration.mysql[:port] }
    let(:username) { RSpec.configuration.mysql[:username] }
    let(:password) { RSpec.configuration.mysql[:password] }

    before(:example) do
      system("mysql -h #{host} --port #{port} -u #{username} -p#{password} -e 'drop database test1'")
    end

    it 'install' do
      # redmine root -> temp dir
      # type of db -> mysql
      # database -> test1
      # host -> configuration
      # username -> configuration
      # password -> configuration
      # encoding -> utf8
      # port -> configuration
      # email configuration -> skip

      allow($stdin).to receive(:gets).and_return(
        @dir, '1', 'test1', host, username, password, 'utf8', port, '999'
      )

      r_installer = Redmine::Installer::Install.new(package1, {})
      expect { r_installer.run }.to_not raise_error
    end
  end

end
