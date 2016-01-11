class ChangeProposalsDistrictToInteger < ActiveRecord::Migration
  def up
    change_column :proposals, :district, 'integer USING CAST(district AS integer)'
  end

  def down
    change_column :proposals, :district, :string
  end
end
