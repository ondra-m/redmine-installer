module Redmine::Installer::Plugin
  class WebServer < Base

    # Generate config based on class and redmine_root.
    # Texts are in lang files.
    def self.generate_config(redmine_root)
      translate("plugin.#{self.superclass.class_name.downcase}.#{self.class_name.downcase}.configuration", redmine_root: redmine_root)
    end

    class Webrick < WebServer
    end

    class Thin < WebServer
    end

    class ApachePassenger < WebServer
    end

    class NginxPassenger < WebServer
    end

    class Puma < WebServer
    end

  end
end
