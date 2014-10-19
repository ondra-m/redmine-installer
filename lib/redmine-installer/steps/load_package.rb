require 'fileutils'

module Redmine::Installer::Step
  class LoadPackage < Base

    SUPPORTED_FORMATS = ['.zip']

    def up
      unless File.exist?(base.redmine)
        error :file_not_exist, file: base.redmine
      end

      @type = File.extname(base.redmine)
      unless SUPPORTED_FORMATS.include?(@type)
        error :file_must_have_format, file: base.redmine, formats: SUPPORTED_FORMATS.join(', ')
      end

      @redmine_root = ask(:path_for_redmine_root, default: '.')

      unless Dir.exist?(@redmine_root)
        create_redmine_root 
      end

      unless File.writable?(@redmine_root)
        error t(:dir_is_not_writeable, dir: @redmine_root)
      end

      # Make aboslute path
      @redmine_root = File.expand_path(@target)
      
    end

    private

      # Try create a redmine_root dir
      # When mkdir raise an error (permission problem) method
      # ask user if wants exist or try again
      def create_redmine_root
        begin
          FileUtils.mkdir_p(@redmine_root)
        rescue

          choices = {}
          choices[:exit] = t(:exit)
          choices[:try_again] = t(:try_again)

          answer = choose(:redmine_root_not_exist_and_cannot_be_created, choices, default: :exit)

          case answer
          when :exit
            exit
          when :try_again
            create_redmine_root
          end
        end
      end

  end
end
