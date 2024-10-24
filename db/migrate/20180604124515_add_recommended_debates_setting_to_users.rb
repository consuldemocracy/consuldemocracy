class AddRecommendedDebatesSettingToUsers < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.boolean :recommended_debates, default: false
    end
  end
end
