class AddExtraFieldsToPages < ActiveRecord::Migration
  def change

    add_column :site_customization_pages, :show_in_cover_flag, :boolean, default: false
    add_column :site_customization_pages, :highlight_in_cover_flag, :boolean, default: false
    add_column :site_customization_pages, :cover_position, :integer, default: nil
    add_column :site_customization_pages, :process_url, :string, default: nil
    add_column :site_customization_pages, :date_information, :string, default: nil
  end
end
