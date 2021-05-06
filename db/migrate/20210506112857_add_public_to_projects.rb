class AddPublicToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :public, :boolean
  end
end
