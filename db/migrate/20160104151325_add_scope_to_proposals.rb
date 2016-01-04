class AddScopeToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :scope, :string
  end
end
