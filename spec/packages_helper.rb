module PackagesHelper

  def package_v310
    File.expand_path(File.join(File.dirname(__FILE__), 'packages', 'redmine-3.1.0.zip'))
  end

  def package_someting_else
    File.expand_path(File.join(File.dirname(__FILE__), 'packages', 'something-else.zip'))
  end

end
