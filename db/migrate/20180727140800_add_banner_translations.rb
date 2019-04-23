class AddBannerTranslations < ActiveRecord::Migration[4.2]

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

