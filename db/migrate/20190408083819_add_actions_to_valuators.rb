class AddActionsToValuators < ActiveRecord::Migration[4.2]
  def change
    add_column :valuators, :can_comment, :boolean, default: true
    add_column :valuators, :can_edit_dossier, :boolean, default: true
  end
end
