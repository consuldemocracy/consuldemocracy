class CreateUserOnProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :user_on_projects do |t|
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
