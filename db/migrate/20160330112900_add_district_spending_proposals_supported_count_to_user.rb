class AddDistrictSpendingProposalsSupportedCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :district_wide_spending_proposals_supported_count, :integer, default: 0
    add_column :users, :city_wide_spending_proposals_supported_count, :integer, default: 0
    add_column :users, :supported_spending_proposals_geozone_id, :integer
  end
end
