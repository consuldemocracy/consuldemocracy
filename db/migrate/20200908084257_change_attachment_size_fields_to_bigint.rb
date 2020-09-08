class ChangeAttachmentSizeFieldsToBigint < ActiveRecord::Migration[5.1]
  def change
    change_column :site_customization_images, :image_file_size, :bigint
    change_column :images, :attachment_file_size, :bigint
    change_column :documents, :attachment_file_size, :bigint
  end
end
