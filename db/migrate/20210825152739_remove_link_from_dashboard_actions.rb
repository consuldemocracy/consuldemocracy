class RemoveLinkFromDashboardActions < ActiveRecord::Migration[5.2]
  def change
    remove_column :dashboard_actions, :link, :string
  end
end
