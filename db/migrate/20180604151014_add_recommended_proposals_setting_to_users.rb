class AddRecommendedProposalsSettingToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :recommended_proposals, default: false
    end
  end
end
