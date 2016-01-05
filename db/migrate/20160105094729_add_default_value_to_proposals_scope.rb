class AddDefaultValueToProposalsScope < ActiveRecord::Migration
  def change
    change_column :proposals, :scope, :string, default: 'district'
  end
end
