require 'ruby-progressbar'
require 'fileutils'
require 'zip'
require 'tmpdir'

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
      @redmine_root = File.expand_path(@redmine_root)

      # Make temp directory and extract archive + move it to the redmine_folder
      extract_and_move_to_redmine_root

      base.redmine_root = @redmine_root
      Dir.chdir(@redmine_root)
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

      def extract_and_move_to_redmine_root
        @tmpdir = Dir.mktmpdir

        case @type
        when '.zip'
          extract_zip
        end

        move_to_redmine_root
      ensure
        FileUtils.remove_entry_secure(@tmpdir)
      end

      def extract_zip
        Zip::File.open(base.redmine) do |zip_file|
          # Progressbar
          progressbar = ProgressBar.create(format: '%a |%b>%i| %p%% %t', total: zip_file.size)

          zip_file.each do |entry|
            dest_file = File.join(@tmpdir, entry.name)
            FileUtils.mkdir_p(File.dirname(dest_file))

            entry.extract(dest_file)
            progressbar.increment
          end
        end
      end

      # Move files from temp dir to target. First check
      # if folder contains redmine or contains
      # folder which contains redmine :-)
      #
      # Package can have format:
      # |-- redmine-2
      #     |-- app
      #     `-- config
      # ...
      #
      def move_to_redmine_root
        redmine_root = @tmpdir

        loop {
          ls = Dir.glob(File.join(redmine_root, '*'))

          if ls.size == 1
            redmine_root = ls.first
          else
            break
          end
        }

        # Move all files from redmine_root
        FileUtils.mv(
          Dir.glob(File.join(redmine_root, '*')),
          @redmine_root
        )
      end

  end
end
