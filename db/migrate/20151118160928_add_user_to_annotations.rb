class AddUserToAnnotations < ActiveRecord::Migration
  def change
    add_reference :annotations, :user, index: true, foreign_key: true
  end
end
