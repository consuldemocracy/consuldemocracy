class AddPollQuestionTranslations < ActiveRecord::Migration

  def self.up
    Poll::Question.create_translation_table!(
      { title: :string },
      { migrate_data: true }
    )
  end

  def self.down
    Poll::Question.drop_translation_table!
  end

end
