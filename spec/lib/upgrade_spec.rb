require 'spec_helper'

RSpec.describe RedmineInstaller::Upgrade, command: 'upgrade' do

  before(:all) do
    @redmine_root = @origin_redmine = Dir.mktmpdir('redmine_root')
    @process = InstallerProcess.new('install', package_v310, @origin_redmine)
    @process.run do
      expected_successful_configuration
      expected_successful_installation

      expected_redmine_version('3.1.0')
    end
    @backup_dir = Dir.mktmpdir('backup_dir')
  end

  after(:all) do
    FileUtils.remove_entry(@origin_redmine)
    FileUtils.remove_entry(@backup_dir)
  end

  before(:each) do
    FileUtils.cp_r(File.join(@origin_redmine, '.'), @redmine_root)
  end

  it 'bad redmine root', args: [] do
    FileUtils.remove_entry(File.join(@redmine_root, 'app'))
    write(@redmine_root)

    expected_output("Redmine #{@redmine_root} is not valid.")
  end

  it 'upgrading with full backup' do
    expected_output('Path to redmine root:')
    write(@redmine_root)

    expected_output('Path to package:')
    write(package_v320)

    expected_output('Extracting redmine package')
    expected_output('Data backup')

    expected_output('‣ Full (redmine root and database)')
    select_choice

    expected_output('Where to save backup:')
    write(@backup_dir)

    expected_output('Files backuping')
    expected_output('Files backed up')
    expected_output('Database backuping')
    expected_output('Database backed up')

    expected_successful_upgrade

    expected_redmine_version('3.2.0')

    binding.pry unless $__binding
  end

end
