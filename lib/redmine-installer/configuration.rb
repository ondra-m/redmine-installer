module RedmineInstaller
  ##
  # RedmineInstaller::Configuration
  #
  # For now, email is only configured.
  #
  class Configuration
    extend Utils

    def self.create_config(redmine)
      # Maybe: enum_select
      klass = prompt.select('Which service to use for email sending?') do |menu|
        menu.default 4

        menu.choice 'Custom configuration (SMTP)', CustomConfiguration
        menu.choice 'Gmail', Gmail
        menu.choice 'SendMail', SendMail
        menu.choice 'Nothing', Nothing
      end

      # Get parameters and create configuration
      database = klass.new(redmine)
      database.get_parameters
      database.make_config
      database
    end

    class Base
      include RedmineInstaller::Utils

      def initialize(redmine)
        @redmine = redmine
      end

      def get_parameters
        @username = prompt.ask('Username:', required: true)
        @password = prompt.mask('Password:', required: true)
      end

      def make_config
        File.open(@redmine.configuration_yml_path, 'w') do |f|
          f.puts(YAML.dump(build))
        end
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

      def delivery_method
        :smtp
      end

      def delivery_settings
        settings = {}

        # Required
        settings['address'] = @address
        settings['port']    = @port

        # Optional
        settings['authentication']       = @authentication  unless @authentication.to_s.empty?
        settings['domain']               = @domain          unless @domain.to_s.empty?
        settings['user_name']            = @user_name       unless @user_name.to_s.empty?
        settings['password']             = @password        unless @password.to_s.empty?
        settings['enable_starttls_auto'] = @enable_starttls unless @enable_starttls.to_s.empty?
        settings['openssl_verify_mode']  = @openssl_verify  unless @openssl_verify.to_s.empty?

        settings
      end

      def to_s
        "<#{class_name} #{@username}@#{@address}:#{@port}>"
      end

    end

    class Nothing < Base

      def get_parameters(*) end
      def make_config(*) end

      def to_s(*)
        "<Nothing>"
      end

    end

    class Gmail < Base

      def get_parameters
        super
        @address = 'smtp.gmail.com'
        @port = 587
        @domain = 'smtp.gmail.com'
        @authentication = :plain
        @enable_starttls = true
      end

    end

    class CustomConfiguration < Base

      def get_parameters
        super
        @address = prompt.ask('Address:', required: true)
        @port = prompt.ask('Port:', convert: :int, required: true)
        @domain = prompt.ask('Domain:')
        @authentication = prompt.ask('Authentication:')
        @openssl_verify = prompt.ask('Openssl verify mode:')
        @enable_starttls = prompt.yes?('Enable starttls?:', default: true)
      end

    end

    class SendMail < Base

      def get_parameters
        @location = prompt.ask('Location:', default: '/usr/sbin/sendmail', required: true)
        @arguments = prompt.ask('Arguments:', default: '-i -t')
      end

      def delivery_method
        :sendmail
      end

      def delivery_settings
        {
          'location' => @location,
          'arguments' => @arguments
        }
      end

      def to_s
        "<SendMail #{@location} #{@arguments}>"
      end

    end

  end
end
