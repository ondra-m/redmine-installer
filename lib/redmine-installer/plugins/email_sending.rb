module Redmine::Installer::Plugin
  class EmailSending < Base

    CONFIGURATION_YML_PATH = 'config/configuration.yml'

    attr_reader :params

    def initialize
      @params = Redmine::Installer::ConfigParams.new
      @params.add('user_name')
      @params.add('password').hide(true)
    end

    def build
      {
        'default' => {
          'email_delivery' => {
            'delivery_method' => delivery_method,
            "#{delivery_method}_settings" => delivery_settings
          }
        }
      }
    end

    def make_config(redmine_root)
      File.open(File.join(redmine_root, CONFIGURATION_YML_PATH), 'w') do |f|
        f.puts(YAML.dump(build))
      end
    end

    def delivery_method
      :smtp
    end

    # Build ConfigParams
    def delivery_settings
      settings = {}
      @params.each do |param|
        next if param.value.empty?
        settings[param.name] = param.value
      end
      settings
    end
  end

  class Gmail < EmailSending
    def delivery_settings
      super.merge({
        'enable_starttls_auto' => true,
        'address' => 'smtp.gmail.com',
        'port' => 587,
        'domain' => 'smtp.gmail.com',
        'authentication' => :plain
      })
    end
  end

  class SendMail < EmailSending
    def initialize
      @params = Redmine::Installer::ConfigParams.new
      @params.add('location').default('/usr/sbin/sendmail')
      @params.add('arguments').default('-i -t')
    end

    def delivery_method
      :sendmail
    end
  end

  class SMTPFromScratch < EmailSending
    def initialize
      @params = Redmine::Installer::ConfigParams.new
      @params.add('address')
      @params.add('port').default(587)
      @params.add('domain')
      @params.add('user_name')
      @params.add('password')
      @params.add('authentication')
      @params.add('enable_starttls_auto')
    end
  end
end
