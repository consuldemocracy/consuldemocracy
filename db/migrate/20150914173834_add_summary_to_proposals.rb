class AddSummaryToProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :summary, :text, limit: 280
  end
end
