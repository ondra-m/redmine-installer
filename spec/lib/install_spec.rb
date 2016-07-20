require 'spec_helper'

RSpec.describe RedmineInstaller::Install do

  def self.package_v310
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'packages', 'redmine-3.1.0.zip'))
  end

  def self.package_someting_else
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'packages', 'something-else.zip'))
  end

  around(:each) do |example|
    @process = RedmineInstallerProcess.new('install', example.metadata[:args])
    @process.run do
      Dir.mktmpdir('redmine_root') do |dir|
        @redmine_root = dir
        example.run
      end
    end
  end

  def expected_output(text)
    expect(@process).to have_output(text)
  end

  def expected_output_in(text, max_wait)
    expect(@process).to have_output_in(text, max_wait)
  end

  def write(text)
    @process.write(text)
  end

  def expected_successful_configuration
    expected_output('Creating database configuration')
    expected_output('What database do you want use?')
    expected_output('‣ MySQL')

    write(TTY::Prompt::Reader::Codes::KEY_DOWN)
    expected_output('‣ PostgreSQL')
    write(' ')

    expected_output('Database:')
    write('test')

    expected_output('Host: (localhost)')
    write('')

    expected_output('Username:')
    write('postgres')

    expected_output('Password:')
    write('postgres')

    expected_output('Encoding: (utf8)')
    write('')

    expected_output('Port: (5432)')
    write('')

    expected_output('Creating email configuration')
    expected_output('Which service to use for email sending?')
    expected_output('‣ Nothing')
    write(' ')
  end

  def expected_successful_installation
    expected_output('Redmine installing')
    expected_output_in('--> Bundle install', 50)
    expected_output_in('--> Database creating', 50)
    expected_output_in('--> Database migrating', 50)
    expected_output_in('--> Plugins migration', 50)
    expected_output_in('--> Generating secret token', 50)

    expected_output('Cleaning root ... OK')
    expected_output('Moving redmine to target directory ... OK')
    expected_output('Cleanning up ... OK')
    expected_output('Moving installer log ... OK')

    expected_output('Redmine was installed')
  end

  def expected_redmine_version(version)
    Dir.chdir(@redmine_root) do
      out = `rails runner "puts Redmine::VERSION.to_s"`
      expect($?.success?).to be_truthy
      expect(out).to include(version)
    end
  end

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

    expected_output_in('Downloading redmine 3.1.1', 20)
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

    expected_output('Could not locate Gemfile')
    expected_output('‣ Try again')

    write(TTY::Prompt::Reader::Codes::KEY_DOWN)
    write(TTY::Prompt::Reader::Codes::KEY_DOWN)
    expected_output('‣ Cancel')
    write(' ')

    expected_output('Operation canceled by user')
  end

  it 'bad database settings', args: [package_v310] do
    write(@redmine_root)

    expected_output('Creating database configuration')

    write(TTY::Prompt::Reader::Codes::KEY_DOWN)
    expected_output('‣ PostgreSQL')
    write(' ')

    write('test')
    write('')
    write('testtesttest')
    sleep 0.5 # wait for buffer
    write('postgres')
    write('')
    write('')

    expected_output('Creating email configuration')
    write(' ')

    expected_output('Redmine installing')
    expected_output_in('--> Database migrating', 60)
    expected_output('Migration end with error')
    expected_output('‣ Try again')

    write(TTY::Prompt::Reader::Codes::KEY_DOWN)
    expected_output('‣ Change database configuration')
    write(' ')

    write(TTY::Prompt::Reader::Codes::KEY_DOWN)
    expected_output('‣ PostgreSQL')
    write(' ')

    write('test')
    write('')
    write('postgres')
    sleep 0.5 # wait for buffer
    write('postgres')
    write('')
    write('')

    expected_output('--> Database migrating')
    expected_output_in('Redmine was installed', 60)

    expected_redmine_version('3.1.0')
  end

  # it 'package', args: ['/home/ondra/Downloads/redmine-3.3.0.zip'] do
  #   binding.pry unless $__binding
  # end

  # it 'package, root', args: ['/home/ondra/Downloads/redmine-3.3.0.zip', 'test'] do
  #   binding.pry unless $__binding
  # end

end
