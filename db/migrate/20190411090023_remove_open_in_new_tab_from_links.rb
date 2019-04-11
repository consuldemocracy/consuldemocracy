class RemoveOpenInNewTabFromLinks < ActiveRecord::Migration
  def change
    remove_column :links, :open_in_new_tab, :boolean
  end
end
