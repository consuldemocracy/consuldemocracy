class ChangeLegislationProposalTitleType < ActiveRecord::Migration
  def change
    change_column :legislation_proposals, :title, :text
  end
end
