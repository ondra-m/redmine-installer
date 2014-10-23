##
# Class for easyier handle configuration parameters
#
# == Examples:
#
#   params = Redmine::Installer::ConfigParams.new
#   params.add('database')
#   params.add('host').note('this is a host').default('localhost')
#
module Redmine::Installer
  class ConfigParams
    def initialize
      @params = []
    end

    def [](key)
      @params.detect{|p| p.name == key}
    end

    def for_asking
      @for_asking ||= @params.select{|p| p.ask}
    end

    def add(name)
      param = ConfigParam.new(name)
      @params << param
      param
    end

    def each(&block)
      @params.each(&block)
    end

    def map(&block)
      @params.map(&block)
    end
  end

  class ConfigParam

    @@attributes = []

    def self.attribute(name, default=nil)
      eval <<-EVAL
        def #{name}(value=nil)
          return @#{name} if value.nil?
          self.#{name} = value
        end

        def #{name}=(value)
          @#{name} = value
        end
      EVAL

      @@attributes << [name, default]
    end

    attribute :name
    attribute :note
    attribute :default
    attribute :value
    attribute :ask, true

    def initialize(name)
      # Default
      @@attributes.each{|(k,v)| set(k,v)}

      set(:name, name)
    end

    # Return string for print
    def title
      out = name.capitalize
      out << " (#{note})" if note
      out
    end

    def set(key, value)
      self.send("#{key}=", value)
    end

    def default(value=nil)
      return @default if value.nil?

      self.default = value
      self.value = value if self.value.nil?
    end

  end
end
