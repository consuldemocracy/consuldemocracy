namespace :active_storage do
  desc "Updates ActiveStorage::Attachment old records created when we were also using paperclip"
  task remove_paperclip_compatibility_in_existing_attachments: :environment do
    ActiveStorage::Attachment.where("name ILIKE 'storage_%'")
                             .where.not(record_type: "Ckeditor::Asset")
                             .update_all("name = replace(name, 'storage_', '')")
  end
end
