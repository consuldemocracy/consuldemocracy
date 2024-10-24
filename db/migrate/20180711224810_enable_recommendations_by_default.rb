class EnableRecommendationsByDefault < ActiveRecord::Migration[4.2]
  def change
    change_column_default :users, :recommended_debates, from: false, to: true
    change_column_default :users, :recommended_proposals, from: false, to: true
  end
end
