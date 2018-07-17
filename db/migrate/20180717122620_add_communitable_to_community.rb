class AddCommunitableToCommunity < ActiveRecord::Migration
  def change
    add_column :communities, :communitable_id, :integer
    add_column :communities, :communitable_type, :string
  end
end
