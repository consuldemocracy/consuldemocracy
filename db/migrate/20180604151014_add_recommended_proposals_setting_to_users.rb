class AddRecommendedProposalsSettingToUsers < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.boolean :recommended_proposals, default: false
    end
  end
end
