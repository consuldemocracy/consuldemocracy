class AddCommentsTranslations < ActiveRecord::Migration[4.2]
  def self.up
    Comment.create_translation_table!(
      {
        body:               :text
       },
      { migrate_data: true }
    )
  end

  def self.down
    Comment.drop_translation_table!
  end
end
