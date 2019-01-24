class AddTranslatePages < ActiveRecord::Migration
  def self.up
    SiteCustomization::Page.create_translation_table!(
      {
        title:    :string,
        subtitle: :string,
        content:  :text
      },
      { migrate_data: true }
    )

    change_column :site_customization_pages, :title, :string, :null => true
  end

  def self.down
    SiteCustomization::Page.drop_translation_table!
    change_column :site_customization_pages, :title, :string, :null => false
  end
end
