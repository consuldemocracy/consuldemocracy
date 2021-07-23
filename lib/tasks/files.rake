namespace :files do
  desc "Removes cached attachments which weren't deleted for some reason"
  task remove_old_cached_attachments: :environment do
    paths = Dir.glob(Rails.root.join("public/system/*/cached_attachments/**/*"))
    logger = ApplicationLogger.new

    paths.each do |path|
      if File.file?(path)
        if File.mtime(path) < 1.day.ago
          File.delete(path)
          logger.info "The file #{path} has been removed"
        end
      else
        Dir.delete(path) if Dir.empty?(path)
      end
    end
  end
end
