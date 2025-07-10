class AddSummaryAndDescriptionToPolls < ActiveRecord::Migration[4.2]
  def change
    add_column :polls, :summary, :text
    add_column :polls, :description, :text
  end
end
