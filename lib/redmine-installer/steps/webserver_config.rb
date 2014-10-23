module Redmine::Installer::Step
  class WebserverConfig < Base

    def up
      choices = {}
      plugin::WebServer.all.each do |m|
        choices[m] = m.title
      end
      choices[nil] = t(:skip)

      answer = choose(:"what_web_server_do_you_want", choices, default: nil)

      # Skip
      return if answer.nil?

      say("(#{answer.title  })", 5)

      say(answer.generate_config(base.redmine_root))
    end

  end
end
