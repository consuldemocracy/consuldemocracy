class RemovePaperclipColumnsFromSiteCustomizationImages < ActiveRecord::Migration[8.0]
  def change
    change_table :site_customization_images do |t|
      t.remove :image_file_name, type: :string
      t.remove :image_content_type, type: :string
      t.remove :image_file_size, type: :bigint
      t.remove :image_updated_at, type: :datetime
    end
  end
end
