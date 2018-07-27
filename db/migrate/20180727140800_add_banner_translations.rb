class AddBannerTranslations < ActiveRecord::Migration

  def self.up
    Banner.create_translation_table!(
      title:       :string,
      description: :text
    )
  end

  def self.down
    Banner.drop_translation_table!
  end
end

