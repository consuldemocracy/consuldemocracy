class AddPhysicalToPollBooths < ActiveRecord::Migration
  def change
    add_column :poll_booths, :physical, :boolean, default: true
  end
end
