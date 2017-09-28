class AddSummaryAndDescriptionToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :summary, :text
    add_column :polls, :description, :text
  end
end
