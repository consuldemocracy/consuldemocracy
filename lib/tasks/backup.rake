require "fileutils"
require "zip"
require "rmega"
require "net/ftp"

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
  desc "Perform all actions to generate and store a backup"
  task perform: ["generate", "upload_to_mega", "upload_to_synology"]

  desc "Delete old backup locally and generate a new backup"
  task generate: :environment do
    if Rails.application.secrets.backup_name.present?
      backup_folder_name = "#{Rails.application.secrets.backup_name}-#{Rails.env}"
      backup_folder = "/home/deploy/#{backup_folder_name}"
      files = {
        "/home/deploy/consul/shared/config" => "#{backup_folder}/config.zip",
        "/home/deploy/consul/shared/public" => "#{backup_folder}/public.zip",
        "/home/deploy/consul/shared/storage" => "#{backup_folder}/storage.zip",
        "/home/deploy/backups" => "#{backup_folder}/database.zip"
      }

      print "Deleting old backups - "
      FileUtils.rm_rf(backup_folder)
      puts "Finished!"

      print "Generating new backups - "
      FileUtils.mkdir_p(backup_folder)
      files.each do |folder, zip_file|
        ZipFileGenerator.new(folder, zip_file).write
      end
      puts "Finished!"
    else
      puts "Skipping backup preparation because of missing secrets key backup_name"
    end
  end

  desc "Upload the backup to the cloud Mega"
  task upload_to_mega: :environment do
    if [Rails.application.secrets.mega_username.present?,
        Rails.application.secrets.mega_password.present?].all?

      backup_folder_name = "#{Rails.application.secrets.backup_name}-#{Rails.env}"
      backup_folder = "/home/deploy/#{backup_folder_name}"

      mega_username = Rails.application.secrets.mega_username
      mega_password = Rails.application.secrets.mega_password
      storage = Rmega.login(mega_username, mega_password)

      if File.exist?(backup_folder)
        print "Uploading backup to Mega - "
        storage.root.folders.each { |f| f.delete if f.name == backup_folder_name }

        folder = storage.root.create_folder(backup_folder_name)
        Dir["#{backup_folder}/*"].each do |file|
          folder.upload(file) unless File.directory?(file)
        end
        puts "Finished!"
      else
        puts "Skipping upload backup to Mega because backup was not generated"
      end
    else
      puts "Skipping upload backup to Mega because of missing secrets keys mega_username or mega_password"
    end
  end

  desc "Upload the backup to the synology"
  task upload_to_synology: :environment do
    if [Rails.application.secrets.synology_host.present?,
        Rails.application.secrets.synology_username.present?,
        Rails.application.secrets.synology_password.present?].all?

      backup_folder_name = "#{Rails.application.secrets.backup_name}-#{Rails.env}"
      backup_folder = "/home/deploy/#{backup_folder_name}"

      host = Rails.application.secrets.synology_host
      synology_username = Rails.application.secrets.synology_username
      synology_password = Rails.application.secrets.synology_password
      synology = Net::FTP.new(host, username: synology_username, password: synology_password)
      synology.login rescue Net::FTPPermError

      if File.exist?(backup_folder)
        print "Uploading backup to Synology - "
        synology.mkdir(backup_folder_name) unless synology.nlst.include?(backup_folder_name)
        synology.nlst(backup_folder_name) do |file|
          synology.delete(file)
        end

        Dir["#{backup_folder}/*"].each do |file|
          synology.put(file, "#{backup_folder_name}/#{File.basename(file)}")
        end
        puts "Finished!"
      else
        puts "Skipping upload backup to Synology because backup was not generated"
      end
    else
      puts "Skipping upload backup to Synology because of missing secrets keys mega_username or mega_password"
    end
  end
end
