class RemoveExternalLinkFromDebates < ActiveRecord::Migration
  def change
    remove_column :debates, :external_link
  end
end
