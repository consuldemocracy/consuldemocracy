class AddSummaryToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :summary, :text, limit: 280
  end
end
