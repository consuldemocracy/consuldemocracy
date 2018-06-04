class AddRecommendedDebatesSettingToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :recommended_debates, default: false
    end
  end
end
