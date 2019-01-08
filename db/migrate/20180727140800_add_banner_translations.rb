class AddBannerTranslations < ActiveRecord::Migration

  def self.up
    Banner.create_translation_table!(
      {
        title:       :string,
        description: :text
      },
      { migrate_data: true }
    )
  end

  def self.down
    Banner.drop_translation_table!
  end
end

