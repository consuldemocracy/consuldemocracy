class AddRetiredTextsToProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :retired_reason, :string, default: nil
    add_column :proposals, :retired_explanation, :text, default: nil
  end
end
