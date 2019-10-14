class AddAsFeaturedFieldToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :featured_image_flag, :boolean, default: false, null: nil
  end
end
