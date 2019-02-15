class RenameOldTranslatableAttibutesInProposals < ActiveRecord::Migration
  def change
    remove_index :proposals, :title
    remove_index :proposals, :question
    remove_index :proposals, :summary

    rename_column :proposals, :title, :deprecated_title
    rename_column :proposals, :description, :deprecated_description
    rename_column :proposals, :question, :deprecated_question
    rename_column :proposals, :summary, :deprecated_summary
    rename_column :proposals, :retired_explanation, :deprecated_retired_explanation
  end
end
