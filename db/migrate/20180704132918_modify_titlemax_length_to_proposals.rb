class ModifyTitlemaxLengthToProposals < ActiveRecord::Migration

  def up
    change_column :proposals, :title, :string, limit: 120 if Setting['org_name'] == 'MASDEMOCRACIAEUROPA'
  end

  def down
    change_column :proposals, :title, :string, limit: 80 if Setting['org_name'] == 'MASDEMOCRACIAEUROPA'
  end

end
