class AddSelectedToProposal < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :selected, :bool, default: false
  end
end
