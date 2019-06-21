class RemoveExternalLinkFromDebates < ActiveRecord::Migration[4.2]
  def change
    remove_column :debates, :external_link
  end
end
