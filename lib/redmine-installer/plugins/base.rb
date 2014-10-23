module Redmine::Installer::Plugin
  class Base

    include Redmine::Installer::Utils
    
    # Register children
    def self.inherited(child)
      all << child
    end

    def self.all
      unless self.instance_variable_defined?(:@all)
        self.instance_variable_set(:@all, Array.new)
      end
      
      self.instance_variable_get(:@all)
    end

    def self.title
      translate("plugin.#{self.superclass.class_name.downcase}.#{self.class_name.downcase}.title")
    end

    # def self.plugin_name
    #   binding.pry unless @__binding
    # end

  end
end
