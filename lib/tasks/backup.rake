require "rmega"
require "zip"

class ZipFileGenerator
  def initialize(input_dir, output_file)
    @input_dir = input_dir
    @output_file = output_file
  end

  def write
    entries = Dir.entries(@input_dir) - %w[. ..]

    ::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
      write_entries entries, "", zipfile
    end
  end

  private

    def write_entries(entries, path, zipfile)
      entries.each do |e|
        zipfile_path = path == "" ? e : File.join(path, e)
        disk_file_path = File.join(@input_dir, zipfile_path)

        if File.directory? disk_file_path
          recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
        else
          put_into_archive(disk_file_path, zipfile, zipfile_path)
        end
      end
    end

    def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
      zipfile.mkdir zipfile_path
      subdir = Dir.entries(disk_file_path) - %w[. ..]
      write_entries subdir, zipfile_path, zipfile
    end

    def put_into_archive(disk_file_path, zipfile, zipfile_path)
      zipfile.add(zipfile_path, disk_file_path)
    end
end

namespace :backup do
  desc "Create a backup and stores in the cloud Mega"
  task mega: :environment do
    if Rails.application.secrets.mega_username.present? && Rails.application.secrets.mega_password.present?
      mega_username = Rails.application.secrets.mega_username
      mega_password = Rails.application.secrets.mega_password
      storage = Rmega.login(mega_username, mega_password)

      files = {
        "/home/deploy/consul/shared/config" => "/home/deploy/config.zip",
        "/home/deploy/consul/shared/public" => "/home/deploy/public.zip",
        "/home/deploy/consul/shared/storage" => "/home/deploy/storage.zip",
        "/home/deploy/backups" => "/home/deploy/database.zip"
      }

      print "Creating backup - "
      files.each do |folder, zip_file|
        File.delete(zip_file) if File.exist?(zip_file)
        ZipFileGenerator.new(folder, zip_file).write
      end
      puts "Finished!"

      print "Uploading backup - "
      storage.root.files.last.trash while storage.root.files.any?
      storage.trash.empty! unless storage.trash.empty?
      files.values.each do |zip_file|
        storage.root.upload(zip_file)
      end
      puts "Finished!"
    else
      puts "Skipping task because of missing secrets keys mega_username and/or mega_password"
    end
  end
end
