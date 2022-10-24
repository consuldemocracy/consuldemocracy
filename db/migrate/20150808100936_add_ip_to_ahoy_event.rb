class AddIpToAhoyEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :ahoy_events, :ip, :string
  end
end
