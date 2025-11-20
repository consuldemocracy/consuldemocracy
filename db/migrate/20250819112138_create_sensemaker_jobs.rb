class CreateSensemakerJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :sensemaker_jobs do |t|
      t.datetime :started_at
      t.datetime :finished_at
      t.string :script
      t.integer :pid
      t.text :error
      t.references :user, null: false, foreign_key: true
      t.string :commentable_type, null: false
      t.integer :commentable_id, null: false

      t.timestamps
    end

    add_index :sensemaker_jobs, [:commentable_type, :commentable_id]
  end
end
