class RemoveDefaultValueInUserRecommendations < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.change_default :recommended_debates, from: true, to: nil
      t.change_default :recommended_proposals, from: true, to: nil
    end
  end
end
