require 'ruby-progressbar'
require 'fileutils'
require 'zip'
require 'tmpdir'

module Redmine::Installer::Step
  class LoadPackage < Base

    SUPPORTED_ARCHIVE_FORMATS = ['.zip']

    def up
      case base.options[:source]
      when 'file'
        load_file
      when 'git'
        load_git
      else
        error :error_unsupported_source, source: base.options[:source]
      end
    end

    def final_step
      # Delete tmp_redmine_root
      FileUtils.remove_entry_secure(@tmpdir) if @tmpdir
    end

    private

      # =======================================================================
      # General

      def create_tmp_dir
        @tmpdir = Dir.mktmpdir
      rescue
        FileUtils.remove_entry_secure(@tmpdir)
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
      def get_tmp_redmine_root
        base.tmp_redmine_root = @tmpdir

        loop {
          ls = Dir.glob(File.join(base.tmp_redmine_root, '*'))

          if ls.size == 1
            base.tmp_redmine_root = ls.first
          else
            break
          end
        }
      end


      # =======================================================================
      # File

      def load_file
        unless File.exist?(base.package)
          error :file_not_exist, file: base.package
        end

        @type = File.extname(base.package)
        unless SUPPORTED_ARCHIVE_FORMATS.include?(@type)
          error :file_must_have_format, file: base.package, formats: SUPPORTED_ARCHIVE_FORMATS.join(', ')
        end

        # Make temp directory and extract archive + move it to the redmine_folder
        extract_to_tmp

        # Locate redmine_root in tmpdir
        get_tmp_redmine_root
      end

      def extract_to_tmp
        create_tmp_dir

        case @type
        when '.zip'
          extract_zip
        end
      end

      def extract_zip
        Zip::File.open(base.package) do |zip_file|
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


      # =======================================================================
      # Git

      def load_git
        create_tmp_dir

        # Clone repository
        run_command(command.git_clone(base.package, @tmpdir), :'command.git_clone')

        # Locate redmine_root in tmpdir
        get_tmp_redmine_root
      end

  end
end
