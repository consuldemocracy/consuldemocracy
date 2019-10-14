class AddIpToAhoyEvent < ActiveRecord::Migration
  def change
    add_column :ahoy_events, :ip, :string
  end
end
