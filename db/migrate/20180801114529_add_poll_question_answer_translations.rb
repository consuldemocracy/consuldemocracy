class AddPollQuestionAnswerTranslations < ActiveRecord::Migration

  def self.up
    Poll::Question::Answer.create_translation_table!(
      {
        title:       :string,
        description: :text
      },
      { migrate_data: true }
    )
  end

  def self.down
    Poll::Question::Answer.drop_translation_table!
  end

end
