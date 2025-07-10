class AddHiddenAtToProposalTranslations < ActiveRecord::Migration[4.2]
  def change
    add_column :proposal_translations, :hidden_at, :datetime
    add_index :proposal_translations, :hidden_at
  end
end
