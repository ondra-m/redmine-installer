module Redmine::Installer::Helper
  module GenerateConfig
    
    def create_for(type)
      choices = {}
      type.all.each do |m|
        choices[m] = m.title
      end
      choices[nil] = t(:skip)

      answer = choose(:"what_#{type.class_name.downcase}_do_you_want", choices, default: nil)

      # Skip
      return if answer.nil?

      instance = answer.new

      say("(#{instance.class.name})", 2)
      instance.params.for_asking.each do |p|
        p.value = ask(p.title, default: p.default)
      end

      instance.make_config(base.redmine_root)
    end

  end
end
