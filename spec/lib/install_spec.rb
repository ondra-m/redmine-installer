require 'spec_helper'

RSpec.describe RedmineInstaller::Install do

  # around(:each) do |example,a,b|
  #   # tempfile = Tempfile.new('redmine-installer-output')

  #   stdout_file = File.open('redmine-installer-out', 'w+')
  #   stdout_file.sync = true

  #   # Keep it for "Inappropriate ioctl for device"
  #   stderr_file = File.open('redmine-installer-err', 'w+')
  #   stderr_file.sync = true

  #   args = Array(example.metadata[:args])

  #   @installer_process = ChildProcess.build('bin/redmine', 'install', *args)
  #   @installer_process.io.stdout = stdout_file
  #   @installer_process.io.stderr = stderr_file
  #   @installer_process.environment['REDMINE_INSTALLER_SPEC'] = '1'
  #   @installer_process.duplex = true
  #   @installer_process.detach = true
  #   @installer_process.start

  #   example.run

  #   stdout_file.close
  #   stderr_file.close
  #   @installer_process.stop
  # end

  # def stdin
  #   @installer_process.io.stdin
  # end

  # def stdout
  #   @installer_process.io.stdout
  # end

  # def stderr
  #   @installer_process.io.stderr
  # end

  # def read_new
  #   sleep 1

  #   @seek ||= 0
  #   buffer = ''

  #   stdout.pos = @seek
  #   loop {
  #     out = stdout.read
  #     if out.empty?
  #       # On end
  #       break
  #     else
  #       # There is still change that samoe output come
  #       buffer << out
  #       sleep 0.5
  #     end
  #   }
  #   @seek = stdout.pos
  #   buffer
  # end

  # # TODO: Timeout
  # def read_new_or_wait
  #   while (out = read_new).empty?
  #     sleep 0.1
  #   end
  #   out
  # end

  # def write(text)
  #   stdin << (text + "\n")
  # end

  # def read_new_and_wait_for(text)
  #   buffer = ''
  #   loop {
  #     buffer << read_new
  #     if buffer.include?(text)
  #       break
  #     else
  #       sleep 0.5
  #     end
  #   }
  #   buffer
  # end

  # def expected_output(text)
  #   @pos ||= 0
  #   @buffer ||= ''

  #   stdout.pos = @pos
  # end

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

    expect(@process).to have_output('Path to redmine root:')
    write(redmine_root)

    expect(@process).to have_output('Path to package:')
    write('aaa')

    expect(@process).to have_output("File aaa must have format: .zip, .gz, .tgz")
  end

  it 'non-existinig zip package' do
    redmine_root = Dir.mktmpdir('redmine_root')

    expect(@process).to have_output('Path to redmine root:')
    write(redmine_root)

    expect(@process).to have_output('Path to package:')
    write('aaa.zip')

    expect(@process).to have_output("File doesn't exist")
  end

  xit 'install without arguments', args: [] do
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

    expect(@process).to have_output('Redmine was installed')
    expect(@process).to have_output('Redmine installing')
    expect(@process).to have_output('--> Bundle install')
    expect(@process).to have_output('--> Database creating')
    expect(@process).to have_output('--> Database migrating')
    expect(@process).to have_output('--> Plugins migration')
    expect(@process).to have_output('--> Generating secret token')

    expect(@process).to have_output('Cleaning root ... OK')
    expect(@process).to have_output('Moving redmine to target directory ... OK')
    expect(@process).to have_output('Cleanning up ... OK')
    expect(@process).to have_output('Moving installer log ... OK')
  end

  # it 'package', args: ['/home/ondra/Downloads/redmine-3.3.0.zip'] do
  #   binding.pry unless $__binding
  # end

  # it 'package, root', args: ['/home/ondra/Downloads/redmine-3.3.0.zip', 'test'] do
  #   binding.pry unless $__binding
  # end

end
