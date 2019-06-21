class RenameUserToAuthorInLegislationAnnotations < ActiveRecord::Migration[4.2]
  def change
    rename_column :legislation_annotations, :user_id, :author_id
  end
end
