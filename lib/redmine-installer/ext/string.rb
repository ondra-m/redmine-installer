class String
  unless method_defined?(:camelize)
    # Base on ActiveSupport method
    def camelize
      self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end

  unless method_defined?(:underscore)
    def underscore
      self.gsub(/\A([A-Z])/){$1.downcase}
          .gsub(/([A-Z])/){'_'+$1.downcase}
    end
  end
end
