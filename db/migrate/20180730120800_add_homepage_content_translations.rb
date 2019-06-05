class AddHomepageContentTranslations < ActiveRecord::Migration

  def self.up
    Widget::Card.create_translation_table!(
      {
        label:       :string,
        title:       :string,
        description: :text,
        link_text:   :string
      },
      { migrate_data: true }
    )
  end

  def self.down
    Widget::Card.drop_translation_table!
  end
end

