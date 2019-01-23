class AddHiddenAtToProposalTranslations < ActiveRecord::Migration
  def change
    add_column :proposal_translations, :hidden_at, :datetime
    add_index :proposal_translations, :hidden_at
  end
end
