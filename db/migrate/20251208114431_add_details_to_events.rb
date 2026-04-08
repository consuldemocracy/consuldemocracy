class AddDetailsToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :location, :string, if_not_exists: true
    add_column :events, :event_type, :string, if_not_exists: true
  end
end
