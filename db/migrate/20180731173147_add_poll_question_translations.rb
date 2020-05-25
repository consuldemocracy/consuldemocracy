class AddPollQuestionTranslations < ActiveRecord::Migration[4.2]

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
