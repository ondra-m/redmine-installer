$stdin.sync = true
$stdout.sync = true

module TTY::Cursor

  singleton_methods.each do |name|
    class_eval <<-METHODS

      def #{name}(*)
        ''
      end

      def self.#{name}(*)
        ''
      end

    METHODS
  end

end

class TestPrompt < TTY::Prompt

  def initialize(*args)
    super
    @enabled_color = false
    @pastel = Pastel.new(enabled: false)
  end

end

class TTY::Prompt::Reader::Console

  def get_char(options)
    return input.getc unless input.tty?
    mode.raw(options[:raw]) do
      mode.echo(options[:echo]) { input.getc }
    end
  end

end

RedmineInstaller.instance_variable_set(:@prompt, TestPrompt.new)
RedmineInstaller.instance_variable_set(:@pastel, Pastel.new(enabled: false))
