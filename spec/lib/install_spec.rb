require 'spec_helper'

RSpec.describe RedmineInstaller::Install do

  around(:each) do |example,a,b|
    # tempfile = Tempfile.new('redmine-installer-output')

    stdout_file = File.open('redmine-installer-out', 'w+')
    stdout_file.sync = true

    stderr_file = File.open('redmine-installer-err', 'w+')
    stderr_file.sync = true

    args = Array(example.metadata[:args])

    @installer_process = ChildProcess.build('bin/redmine', 'install', *args)
    @installer_process.io.stdout = stdout_file
    @installer_process.io.stderr = stderr_file
    @installer_process.environment['REDMINE_INSTALLER_SPEC'] = '1'
    @installer_process.duplex = true
    @installer_process.detach = true
    @installer_process.start

    example.run

    stdout_file.close
    stderr_file.close
    @installer_process.stop
  end

  def stdin
    @installer_process.io.stdin
  end

  def stdout
    @installer_process.io.stdout
  end

  def stderr
    @installer_process.io.stderr
  end

  def read_new
    sleep 1

    @seek ||= 0
    buffer = ''

    stdout.pos = @seek
    loop {
      out = stdout.read
      if out.empty?
        # On end
        break
      else
        # There is still change that samoe output come
        buffer << out
        sleep 0.5
      end
    }
    @seek = stdout.pos
    buffer
  end

  # TODO: Timeout
  def read_new_or_wait
    while (out = read_new).empty?
      sleep 0.1
    end
    out
  end

  def write(text)
    stdin << (text + "\n")
  end

  def read_new_and_wait_for(text)
    buffer = ''
    loop {
      buffer << read_new
      if buffer.include?(text)
        break
      else
        sleep 0.5
      end
    }
    buffer
  end

  it 'bad permission', args: [] do
    redmine_root = Dir.mktmpdir('redmine_root')

    system("chmod 000 #{redmine_root}")

    expect(read_new_or_wait).to include('Path to redmine root:')
    write(redmine_root)

    expect(read_new_or_wait).to include('Redmine root contains inaccessible files')
  end

  it 'non-exstinig package' do
    redmine_root = Dir.mktmpdir('redmine_root')

    expect(read_new_or_wait).to include('Path to redmine root:')
    write(redmine_root)

    expect(read_new_or_wait).to include('Path to package:')
    write('aaa')

    expect(read_new_or_wait).to include("File aaa must have format: .zip, .gz, .tgz")
    expect(read_new_or_wait).to include("File doesn't exist")
  end

  it 'non-exstinig package' do
    redmine_root = Dir.mktmpdir('redmine_root')

    expect(read_new_or_wait).to include('Path to redmine root:')
    write(redmine_root)

    expect(read_new_or_wait).to include('Path to package:')
    write('aaa.zip')

    expect(read_new_or_wait).to include("File doesn't exist")
  end

  it 'install without arguments', args: [] do
    redmine_root = Dir.mktmpdir('redmine_root')
    regular_package = File.expand_path(File.join(File.dirname(__FILE__), '..', 'packages', 'redmine-3.1.0.zip'))

    expect(read_new_or_wait).to include('Path to redmine root:')
    write(redmine_root)

    expect(read_new_or_wait).to include('Path to package:')
    write(regular_package)

    out = read_new_or_wait
    expect(out).to include('Extracting redmine package')
    expect(out).to include('Creating database configuration')
    expect(out).to include('What database do you want use?')
    expect(out).to include('‣ MySQL')

    write(TTY::Prompt::Reader::Codes::KEY_DOWN)
    expect(read_new_or_wait).to include('‣ PostgreSQL')
    write(' ')

    expect(read_new_or_wait).to include('Database:')
    write('test')

    expect(read_new_or_wait).to include('Host: (localhost)')
    write('')

    expect(read_new_or_wait).to include('Username:')
    write('postgres')

    expect(read_new_or_wait).to include('Password:')
    write('postgres')

    expect(read_new_or_wait).to include('Encoding: (utf8)')
    write('')

    expect(read_new_or_wait).to include('Port: (5432)')
    write('')

    out = read_new_or_wait
    expect(out).to include('Creating email configuration')
    expect(out).to include('Which service to use for email sending?')
    expect(out).to include('‣ Nothing')
    write(' ')

    out = read_new_and_wait_for('Redmine was installed')
    expect(out).to include('Redmine installing')
    expect(out).to include('--> Bundle install')
    expect(out).to include('--> Database creating')
    expect(out).to include('--> Database migrating')
    expect(out).to include('--> Plugins migration')
    expect(out).to include('--> Generating secret token')

    expect(out).to include('Cleaning root ... OK')
    expect(out).to include('Moving redmine to target directory ... OK')
    expect(out).to include('Cleanning up ... OK')
    expect(out).to include('Moving installer log ... OK')
  end

  # it 'package', args: ['/home/ondra/Downloads/redmine-3.3.0.zip'] do
  #   binding.pry unless $__binding
  # end

  # it 'package, root', args: ['/home/ondra/Downloads/redmine-3.3.0.zip', 'test'] do
  #   binding.pry unless $__binding
  # end

end
