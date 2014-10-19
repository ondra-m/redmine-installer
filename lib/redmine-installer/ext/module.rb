class Module
  unless method_defined?(:camelize)
    def class_name
      name.split('::').last
    end
  end
end
