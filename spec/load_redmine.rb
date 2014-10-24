require 'rest_client'

class LoadRedmine
  
  def self.files
    @files ||= []
  end

  def self.clean
    files.each(&:unlink)
  end

  def self.get(version)
    file = Tempfile.new(['redmine', '.zip'])
    files << file

    file.binmode
    # file.write RestClient.get("http://www.redmine.org/releases/redmine-#{version}.zip")
    file.write RestClient.get("http://localhost:5000/redmine-#{version}.zip")
    file.close
    file.path
  end

end