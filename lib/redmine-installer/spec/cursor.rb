module TTY
  module Cursor

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
end
