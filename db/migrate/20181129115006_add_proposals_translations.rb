class AddProposalsTranslations < ActiveRecord::Migration[4.2]
  def self.up
    Proposal.create_translation_table!(
      {
        title:               :string,
        description:         :text,
        summary:             :text,
        retired_explanation: :text
      },
      { migrate_data: true }
    )
  end

  def self.down
    Proposal.drop_translation_table!
  end
end
