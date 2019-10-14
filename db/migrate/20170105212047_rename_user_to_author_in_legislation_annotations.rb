class RenameUserToAuthorInLegislationAnnotations < ActiveRecord::Migration
  def change
    rename_column :legislation_annotations, :user_id, :author_id
  end
end
