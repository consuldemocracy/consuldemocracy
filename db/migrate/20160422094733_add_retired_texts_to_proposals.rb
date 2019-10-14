class AddRetiredTextsToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :retired_reason, :string, default: nil
    add_column :proposals, :retired_explanation, :text, default: nil
  end
end
