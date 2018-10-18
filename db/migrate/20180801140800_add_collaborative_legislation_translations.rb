class AddCollaborativeLegislationTranslations < ActiveRecord::Migration

  def self.up
    Legislation::Process.create_translation_table!(
      title:           :string,
      summary:         :text,
      description:     :text,
      additional_info: :text,
    )

    Legislation::Question.create_translation_table!(
      title:           :text
    )

    Legislation::DraftVersion.create_translation_table!(
      title:           :string,
      changelog:       :text,
      body:            :text,
      body_html:       :text,
      toc_html:        :text
    )
    Legislation::QuestionOption.create_translation_table!(
      value:           :string
    )
  end

  def self.down
    Legislation::Process.drop_translation_table!
    Legislation::DraftVersion.drop_translation_table!
    Legislation::Question.drop_translation_table!
    Legislation::QuestionOption.drop_translation_table!
  end
end
