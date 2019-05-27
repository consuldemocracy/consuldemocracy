class RemoveOpenInNewTabFromLinks < ActiveRecord::Migration[4.2]
  def change
    remove_column :links, :open_in_new_tab, :boolean
  end
end
