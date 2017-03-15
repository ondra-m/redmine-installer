require 'spec_helper'

RSpec.describe RedmineInstaller::Install, command: 'install' do

  it 'bad permission', args: [] do
    FileUtils.chmod(0000, @redmine_root)

    expected_output('Path to redmine root:')
    write(@redmine_root)

    expected_output('Redmine root contains inaccessible files')

    FileUtils.chmod(0600, @redmine_root)
  end

  it 'non-existinig package', args: [] do
    this_file = File.expand_path(File.join(File.dirname(__FILE__)))

    expected_output('Path to redmine root:')
    write(@redmine_root)

    expected_output('Path to package:')
    write(this_file)

    expected_output("File #{this_file} must have format: .zip, .gz, .tgz")
  end

  it 'non-existinig zip package', args: [] do
    expected_output('Path to redmine root:')
    write(@redmine_root)

    expected_output('Path to package:')
    write('aaa.zip')

    expected_output("File doesn't exist")
  end

  it 'install without arguments', args: [] do
    regular_package = File.expand_path(File.join(File.dirname(__FILE__), '..', 'packages', 'redmine-3.1.0.zip'))

    expected_output('Path to redmine root:')
    write(@redmine_root)

    expected_output('Path to package:')
    write(regular_package)

    expected_output('Extracting redmine package')

    expected_successful_configuration
    expected_successful_installation

    expected_redmine_version('3.1.0')
  end

  it 'download redmine', args: ['v3.1.1'] do
    expected_output('Path to redmine root:')
    write(@redmine_root)

    expected_output_in('Downloading http://www.redmine.org/releases/redmine-3.1.1.zip', 30)
    expected_output('Extracting redmine package')

    expected_successful_configuration
    expected_successful_installation

    expected_redmine_version('3.1.1')
  end

  it 'installing something else', args: [package_someting_else] do
    write(@redmine_root)

    expected_successful_configuration

    expected_output('Redmine installing')
    expected_output_in('--> Bundle install', 50)

    expected_output('Gemfile not found')
    expected_output('‣ Try again')

    go_down
    go_down
    expected_output('‣ Cancel')
    write(' ')

    expected_output('Operation canceled by user')
  end

  it 'bad database settings', args: [package_v310] do
    write(@redmine_root)

    expected_output('Creating database configuration')
    go_down
    expected_output('‣ PostgreSQL')
    write(' ')

    write('test')
    write('')
    write('testtesttest')
    sleep 0.5 # wait for buffer
    write(db_password)
    write('')
    write('')

    expected_output('Creating email configuration')
    write(' ')

    expected_output('Redmine installing')
    expected_output_in('--> Database migrating', 60)
    expected_output('Migration end with error')
    expected_output('‣ Try again')

    go_down
    go_down
    expected_output('‣ Change database configuration')
    write(' ')

    go_down
    expected_output('‣ PostgreSQL')
    write(' ')

    write('test')
    write('')
    write(db_username)
    sleep 0.5 # wait for buffer
    write(db_password)
    write('')
    write('')

    expected_output('--> Database migrating')
    expected_output_in('Redmine was installed', 60)

    expected_redmine_version('3.1.0')
  end

end
