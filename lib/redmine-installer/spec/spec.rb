# $stdin.sync = true
# $stdout.sync = true

# # require 'redmine-installer/spec/cursor'

# class TestPrompt < TTY::Prompt

#   def initialize(*args)
#     # @input  = StringIO.new
#     # @output = StringIO.new
#     # super(input: @input, output: @output)
#     super
#     @pastel = Pastel.new(enabled: false)
#   end

# end

# module RedmineInstaller

#   # def self.prompt
#   #   @prompt ||= TestPrompt.new
#   # end

#   def self.pastel
#     @pastel ||= Pastel.new(enabled: false)
#   end

# end

# module TTY
#   module Cursor

#     singleton_methods.each do |name|
#       class_eval <<-METHODS

#         def #{name}(*)
#           ''
#         end

#         def self.#{name}(*)
#           ''
#         end

#       METHODS
#     end

#   end
# end

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
    @pastel = Pastel.new(enabled: false)
  end

end

RedmineInstaller.instance_variable_set(:@prompt, TestPrompt.new)
RedmineInstaller.instance_variable_set(:@pastel, Pastel.new(enabled: false))
