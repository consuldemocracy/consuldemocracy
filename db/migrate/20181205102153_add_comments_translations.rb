class AddCommentsTranslations < ActiveRecord::Migration
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
