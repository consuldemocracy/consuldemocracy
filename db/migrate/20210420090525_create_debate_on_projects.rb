class CreateDebateOnProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :debate_on_projects do |t|
      t.references :project, foreign_key: true
      t.references :debate, foreign_key: true

      t.timestamps
    end
  end
end
