require 'spec_helper'

RSpec.describe RedmineInstaller::Install do

  around(:each) do |example|
    @process = RedmineInstallerProcess.new('install', example.metadata[:args])
    @process.start
    example.run
    @process.stop
  end

  def write(text)
    @process.write(text)
  end

  it 'bad permission', args: [] do
    redmine_root = Dir.mktmpdir('redmine_root')

    system("chmod 000 #{redmine_root}")

    expect(@process).to have_output('Path to redmine root:')
    write(redmine_root)

    expect(@process).to have_output('Redmine root contains inaccessible files')
  end

  it 'non-existinig package' do
    redmine_root = Dir.mktmpdir('redmine_root')
    this_file = File.expand_path(File.join(File.dirname(__FILE__)))

    expect(@process).to have_output('Path to redmine root:')
    write(redmine_root)

    expect(@process).to have_output('Path to package:')
    write(this_file)

    expect(@process).to have_output("File #{this_file} must have format: .zip, .gz, .tgz")
  end

  it 'non-existinig zip package' do
    redmine_root = Dir.mktmpdir('redmine_root')

    expect(@process).to have_output('Path to redmine root:')
    write(redmine_root)

    expect(@process).to have_output('Path to package:')
    write('aaa.zip')

    expect(@process).to have_output("File doesn't exist")
  end

  it 'install without arguments', args: [] do
    redmine_root = Dir.mktmpdir('redmine_root')
    regular_package = File.expand_path(File.join(File.dirname(__FILE__), '..', 'packages', 'redmine-3.1.0.zip'))

    expect(@process).to have_output('Path to redmine root:')
    write(redmine_root)

    expect(@process).to have_output('Path to package:')
    write(regular_package)

    expect(@process).to have_output('Extracting redmine package')
    expect(@process).to have_output('Creating database configuration')
    expect(@process).to have_output('What database do you want use?')
    expect(@process).to have_output('‣ MySQL')

    write(TTY::Prompt::Reader::Codes::KEY_DOWN)
    expect(@process).to have_output('‣ PostgreSQL')
    write(' ')

    expect(@process).to have_output('Database:')
    write('test')

    expect(@process).to have_output('Host: (localhost)')
    write('')

    expect(@process).to have_output('Username:')
    write('postgres')

    expect(@process).to have_output('Password:')
    write('postgres')

    expect(@process).to have_output('Encoding: (utf8)')
    write('')

    expect(@process).to have_output('Port: (5432)')
    write('')

    expect(@process).to have_output('Creating email configuration')
    expect(@process).to have_output('Which service to use for email sending?')
    expect(@process).to have_output('‣ Nothing')
    write(' ')

    expect(@process).to have_output('Redmine installing')
    expect(@process).to have_output_in('--> Bundle install', 50)
    expect(@process).to have_output_in('--> Database creating', 50)
    expect(@process).to have_output_in('--> Database migrating', 50)
    expect(@process).to have_output_in('--> Plugins migration', 50)
    expect(@process).to have_output_in('--> Generating secret token', 50)

    expect(@process).to have_output('Cleaning root ... OK')
    expect(@process).to have_output('Moving redmine to target directory ... OK')
    expect(@process).to have_output('Cleanning up ... OK')
    expect(@process).to have_output('Moving installer log ... OK')

    expect(@process).to have_output('Redmine was installed')

    Dir.chdir(redmine_root) do
      out = `rails runner "puts Redmine::VERSION.to_s"`
      expect($?.success?).to be_truthy
      expect(out).to include('3.1.0')
    end
  end

  it 'download redmine', args: ['v3.1.1'] do
    redmine_root = Dir.mktmpdir('redmine_root')

    expect(@process).to have_output('Path to redmine root:')
    write(redmine_root)

    expect(@process).to have_output_in('Downloading redmine 3.1.1', 20)
    expect(@process).to have_output('Extracting redmine package')
    expect(@process).to have_output('Creating database configuration')
    expect(@process).to have_output('What database do you want use?')
    expect(@process).to have_output('‣ MySQL')

    write(TTY::Prompt::Reader::Codes::KEY_DOWN)
    expect(@process).to have_output('‣ PostgreSQL')
    write(' ')

    expect(@process).to have_output('Database:')
    write('test')

    expect(@process).to have_output('Host: (localhost)')
    write('')

    expect(@process).to have_output('Username:')
    write('postgres')

    expect(@process).to have_output('Password:')
    write('postgres')

    expect(@process).to have_output('Encoding: (utf8)')
    write('')

    expect(@process).to have_output('Port: (5432)')
    write('')

    expect(@process).to have_output('Creating email configuration')
    expect(@process).to have_output('Which service to use for email sending?')
    expect(@process).to have_output('‣ Nothing')
    write(' ')

    expect(@process).to have_output('Redmine installing')
    expect(@process).to have_output_in('--> Bundle install', 50)
    expect(@process).to have_output_in('--> Database creating', 50)
    expect(@process).to have_output_in('--> Database migrating', 50)
    expect(@process).to have_output_in('--> Plugins migration', 50)
    expect(@process).to have_output_in('--> Generating secret token', 50)

    expect(@process).to have_output('Cleaning root ... OK')
    expect(@process).to have_output('Moving redmine to target directory ... OK')
    expect(@process).to have_output('Cleanning up ... OK')
    expect(@process).to have_output('Moving installer log ... OK')

    expect(@process).to have_output('Redmine was installed')

    Dir.chdir(redmine_root) do
      out = `rails runner "puts Redmine::VERSION.to_s"`
      expect($?.success?).to be_truthy
      expect(out).to include('3.1.1')
    end
  end

  # it 'package', args: ['/home/ondra/Downloads/redmine-3.3.0.zip'] do
  #   binding.pry unless $__binding
  # end

  # it 'package, root', args: ['/home/ondra/Downloads/redmine-3.3.0.zip', 'test'] do
  #   binding.pry unless $__binding
  # end

end
