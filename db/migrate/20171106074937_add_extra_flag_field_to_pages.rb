class AddExtraFlagFieldToPages < ActiveRecord::Migration
  def change
    add_column :site_customization_pages, :show_as_poster_flag, :boolean, default: false, null: nil
  end
end
