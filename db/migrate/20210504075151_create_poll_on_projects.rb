class CreatePollOnProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :poll_on_projects do |t|
      t.references :project, foreign_key: true
      t.references :poll, foreign_key: true

      t.timestamps
    end
  end
end
