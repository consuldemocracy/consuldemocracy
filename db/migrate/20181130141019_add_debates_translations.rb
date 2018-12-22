class AddDebatesTranslations < ActiveRecord::Migration
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
