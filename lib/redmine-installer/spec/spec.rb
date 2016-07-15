$stdin.sync = true
$stdout.sync = true

class TestPrompt < TTY::Prompt

  def initialize(*args)
    # @input  = StringIO.new
    # @output = StringIO.new
    # super(input: @input, output: @output)
    super
    @pastel = Pastel.new(enabled: false)
  end

end

module RedmineInstaller

  # def self.prompt
  #   @prompt ||= TestPrompt.new
  # end

  def self.pastel
    @pastel ||= Pastel.new(enabled: false)
  end

end
