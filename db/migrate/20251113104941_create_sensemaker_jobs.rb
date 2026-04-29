class CreateSensemakerJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :sensemaker_jobs do |t|
      t.datetime :started_at
      t.datetime :finished_at
      t.string :script
      t.integer :pid
      t.text :error
      t.references :user, null: false, foreign_key: true
      t.string :analysable_type, null: false
      t.integer :analysable_id
      t.timestamps
      t.text :additional_context
      t.references :parent_job, foreign_key: { to_table: :sensemaker_jobs }
      t.string :input_file
      t.string :persisted_output
      t.boolean :published, default: false
      t.integer :comments_analysed, default: 0
    end

    add_index :sensemaker_jobs, [:analysable_type, :analysable_id]
  end
end
