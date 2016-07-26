module InstallerHelper

  def expected_output(text)
    expect(@process).to have_output(text)
  end

  def expected_output_in(text, max_wait)
    expect(@process).to have_output_in(text, max_wait)
  end

  def write(text)
    @process.write(text + "\n")
  end

  def select_choice
    @process.write(' ')
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

  def expected_successful_installation_or_upgrade(install: false, upgrade: false)
    expected_output_in('--> Bundle install', 50)
    expected_output_in('--> Database creating', 50) if install
    expected_output_in('--> Database migrating', 50)
    expected_output_in('--> Plugins migration', 50)
    expected_output_in('--> Generating secret token', 50)

    expected_output('Cleaning root ... OK')
    expected_output('Moving redmine to target directory ... OK')
    expected_output('Cleanning up ... OK')
    expected_output('Moving installer log ... OK')
  end

  def expected_successful_installation
    expected_output('Redmine installing')
    expected_successful_installation_or_upgrade(install: true)
    expected_output('Redmine was installed')
  end

  def expected_successful_upgrade
    expected_output('Redmine upgrading')
    expected_successful_installation_or_upgrade(upgrade: true)
    expected_output('Redmine was upgraded')

    expected_output('Do you want save steps for further use?')
    write('n')
  end

  def expected_redmine_version(version)
    Dir.chdir(@redmine_root) do
      out = `rails runner "puts Redmine::VERSION.to_s"`
      expect($?.success?).to be_truthy
      expect(out).to include(version)
    end
  end

  def wait_for_stdin_buffer
    sleep 0.5
  end

end
