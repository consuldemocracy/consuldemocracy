class AddCreatedByToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :created_by, :integer, default: nil, null: true
  end
end
