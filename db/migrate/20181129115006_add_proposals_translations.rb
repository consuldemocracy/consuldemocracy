class AddProposalsTranslations < ActiveRecord::Migration
  def self.up
    Proposal.create_translation_table!(
      {
        title:               :string,
        description:         :text,
        question:            :string,
        summary:             :text,
        retired_reason:      :string,
        retired_explanation: :text

      },
      { migrate_data: true }
    )
  end

  def self.down
    Proposal.drop_translation_table!
  end
end
