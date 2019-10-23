class AddCollaborativeLegislationTranslations < ActiveRecord::Migration[4.2]
  def self.up
    Legislation::Process.create_translation_table!(
      {
        title:           :string,
        summary:         :text,
        description:     :text,
        additional_info: :text,
      },
      { migrate_data: true }
    )

    Legislation::Question.create_translation_table!(
      { title: :text },
      { migrate_data: true }
    )

    Legislation::DraftVersion.create_translation_table!(
      {
        title:     :string,
        changelog: :text,
        body:      :text
      },
      { migrate_data: true }
    )

    add_column :legislation_draft_version_translations, :body_html, :text
    add_column :legislation_draft_version_translations, :toc_html, :text

    Legislation::QuestionOption.create_translation_table!(
      { value: :string },
      { migrate_data: true }
    )
  end

  def self.down
    Legislation::Process.drop_translation_table!
    Legislation::DraftVersion.drop_translation_table!
    Legislation::Question.drop_translation_table!
    Legislation::QuestionOption.drop_translation_table!
  end
end
