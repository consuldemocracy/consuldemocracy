class AddPollTranslations < ActiveRecord::Migration

  def self.up
    Poll.create_translation_table!(
      name:        :string,
      summary:     :text,
      description: :text
    )
  end

  def self.down
    Poll.drop_translation_table!
  end

end
