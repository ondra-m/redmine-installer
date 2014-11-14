require 'rubygems/package'
require 'ruby-progressbar'
require 'fileutils'
require 'zip'
require 'tmpdir'
require 'zlib'

module Redmine::Installer::Step
  class LoadPackage < Base

    SUPPORTED_ARCHIVE_FORMATS = ['.zip', '.gz', '.tgz']
    TAR_LONGLINK = '././@LongLink'
    PROGRESSBAR_FORMAT = '%a [%b>%i] %p%% %t'

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
        when '.gz', '.tgz'
          extract_tar_gz
        end
      end

      def extract_zip
        Zip::File.open(base.package) do |zip_file|
          # Progressbar
          progressbar = ProgressBar.create(format: PROGRESSBAR_FORMAT, total: zip_file.size)

          zip_file.each do |entry|
            dest_file = File.join(@tmpdir, entry.name)
            FileUtils.mkdir_p(File.dirname(dest_file))

            entry.extract(dest_file)
            progressbar.increment
          end
        end
      end

      # Extract .tar.gz archive
      # based on http://dracoater.blogspot.cz/2013/10/extracting-files-from-targz-with-ruby.html
      # 
      # Originally tar did not support paths longer than 100 chars. GNU tar is better and they 
      # implemented support for longer paths, but it was made through a hack called ././@LongLink. 
      # Shortly speaking, if you stumble upon an entry in tar archive which path equals to above 
      # mentioned ././@LongLink, that means that the following entry path is longer than 100 chars and
      # is truncated. The full path of the following entry is actually the value of the current entry.
      #
      def extract_tar_gz
        Gem::Package::TarReader.new(Zlib::GzipReader.open(base.package)) do |tar|

          # Progressbar
          progressbar = ProgressBar.create(format: PROGRESSBAR_FORMAT, total: tar.count)

          # tar.count move position pointer to end
          tar.rewind

          dest_file = nil
          tar.each do |entry|
            if entry.full_name == TAR_LONGLINK
              dest_file = File.join(@tmpdir, entry.read.strip)
              next
            end
            dest_file ||= File.join(@tmpdir, entry.full_name)
            if entry.directory?
              FileUtils.rm_rf(dest_file) unless File.directory?(dest_file)
              FileUtils.mkdir_p(dest_file, mode: entry.header.mode, verbose: false)
            elsif entry.file?
              FileUtils.rm_rf(dest_file) unless File.file?(dest_file)
              File.open(dest_file, 'wb') do |f|
                f.write(entry.read)
              end
              FileUtils.chmod(entry.header.mode, dest_file, verbose: false)
            elsif entry.header.typeflag == '2' # symlink
              File.symlink(entry.header.linkname, dest_file)
            end

            dest_file = nil
            progressbar.increment
          end
        end
      end


      # =======================================================================
      # Git

      def load_git
        create_tmp_dir

        # Package is remote url to git repository
        remote = base.package

        if remote
          # Clone repository
          Git.clone(remote, @tmpdir, base.options['branch'])
        else
          # Copy current repository to tmp and run pull
          Git.copy_and_fetch(base.redmine_root, @tmpdir)
        end

        # Locate redmine_root in tmpdir
        get_tmp_redmine_root
      end

  end
end
