module InstallerHelper

  def db_username
    ENV['SPEC_DB_USERNAME'] || ENV['PGUSER'] || ''
  end

  def db_password
    ENV['SPEC_DB_PASSWORD'] || ENV['PGPASSWORD'] || ''
  end

  def expected_output(text)
    expect(@process).to have_output(text)
  end

  def expected_output_in(text, max_wait)
    expect(@process).to have_output_in(text, max_wait)
  end

  def write(text)
    @process.write(text + "\n")
  end

  # Be carefull - this could have later unpredictable consequences on stdin
  def select_choice
    @process.write(' ')
    # @process.write("\r")
    # @process.write("\r\n")
  end

  def expected_successful_configuration
    expected_output('Creating database configuration')
    expected_output('What database do you want use?')
    expected_output('‣ MySQL')

    write(TTY::Prompt::Reader::Codes::KEY_DOWN)
    expected_output('‣ PostgreSQL')
    select_choice

    expected_output('Database:')
    write('test')

    expected_output('Host: (localhost)')
    write('')

    expected_output('Username:')
    write(db_username)

    expected_output('Password:')
    write(db_password)

    expected_output('Encoding: (utf8)')
    write('')

    expected_output('Port: (5432)')
    write('')

    expected_output('Creating email configuration')
    expected_output('Which service to use for email sending?')
    expected_output('‣ Nothing')
    select_choice
  end

  def expected_successful_installation_or_upgrade(db_creating: false)
    expected_output_in('--> Bundle install', 50)
    expected_output_in('--> Database creating', 50) if db_creating
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
    expected_successful_installation_or_upgrade(db_creating: true)
    expected_output('Redmine was installed')
  end

  def expected_successful_upgrade
    expected_output('Redmine upgrading')
    expected_successful_installation_or_upgrade
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
