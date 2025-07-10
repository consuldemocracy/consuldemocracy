class AddDebatesTranslations < ActiveRecord::Migration[4.2]
  def self.up
    Debate.create_translation_table!(
      {
        title:               :string,
        description:         :text
       },
      { migrate_data: true }
    )
  end

  def self.down
    Debate.drop_translation_table!
  end
end
