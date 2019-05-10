class AddActivePollsTranslations < ActiveRecord::Migration[4.2]

  def self.up
    ActivePoll.create_translation_table!(
      {
        description: :text
      },
      { migrate_data: true }
    )
  end

  def self.down
    ActivePollPoll.drop_translation_table!
  end

end
