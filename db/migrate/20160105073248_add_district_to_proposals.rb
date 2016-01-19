class AddDistrictToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :district, :string
  end
end
