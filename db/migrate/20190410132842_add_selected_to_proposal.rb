class AddSelectedToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :selected, :bool, default: false, index: true
  end
end
