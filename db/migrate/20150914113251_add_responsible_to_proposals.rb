class AddResponsibleToProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :responsible_name, :string, limit: 60
  end
end
