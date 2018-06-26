class AddObjectiveToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :objective, :text
  end
end
