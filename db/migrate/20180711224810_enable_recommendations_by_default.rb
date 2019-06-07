class EnableRecommendationsByDefault < ActiveRecord::Migration
  def change
    change_column_default :users, :recommended_debates, true
    change_column_default :users, :recommended_proposals, true
  end
end
