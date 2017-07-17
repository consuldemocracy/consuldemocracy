class RemoveGeozoneIdFromRedeemableCodes < ActiveRecord::Migration
  def change
    remove_column :redeemable_codes, :geozone_id, :integer
  end
end
