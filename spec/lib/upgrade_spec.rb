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
    test_test_dir = File.join(@redmine_root, 'test_test')
    test_test_file = File.join(test_test_dir, 'test.txt')
    FileUtils.mkdir_p(test_test_dir)
    FileUtils.touch(test_test_file)

    expect(File.exist?(test_test_file)).to be_truthy

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

    expect(File.exist?(test_test_file)).to be_falsey

    last_backup = Dir.glob(File.join(@backup_dir, '*')).sort.last
    backuped = Dir.glob(File.join(last_backup, '*'))

    expect(backuped.map{|f| File.zero?(f) }).to all(be_falsey)
  end

  it 'upgrade with no backup and files keeping', args: ['--keep', 'test_test'] do
    test_test_dir = File.join(@redmine_root, 'test_test')
    test_test_file = File.join(test_test_dir, 'test.txt')
    FileUtils.mkdir_p(test_test_dir)
    FileUtils.touch(test_test_file)

    expect(File.exist?(test_test_file)).to be_truthy

    wait_for_stdin_buffer
    write(@redmine_root)

    wait_for_stdin_buffer
    write(package_v320)

    wait_for_stdin_buffer

    write(TTY::Prompt::Reader::Codes::KEY_DOWN)
    write(TTY::Prompt::Reader::Codes::KEY_DOWN)
    expected_output('‣ Nothing')
    select_choice

    expected_output('Are you sure?')
    write('y')

    expected_successful_upgrade

    expected_redmine_version('3.2.0')

    expect(File.exist?(test_test_file)).to be_truthy
  end

end
