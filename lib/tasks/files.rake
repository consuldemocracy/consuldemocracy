namespace :files do
  desc "Removes cached attachments which weren't deleted for some reason"
  task remove_old_cached_attachments: :environment do
    ActiveStorage::Blob.unattached
                       .where("active_storage_blobs.created_at <= ?", 1.day.ago)
                       .find_each(&:purge_later)
  end
end
