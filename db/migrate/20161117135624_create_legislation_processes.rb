class CreateLegislationProcesses < ActiveRecord::Migration
  def change
    create_table :legislation_processes do |t|
      t.string :title
      t.text :description
      t.text :target
      t.text :how_to_participate
      t.text :additional_info
      t.date :start_date, index: true
      t.date :end_date, index: true
      t.date :debate_start_date, index: true
      t.date :debate_end_date, index: true
      t.date :draft_publication_date, index: true
      t.date :allegations_start_date, index: true
      t.date :allegations_end_date, index: true
      t.date :final_publication_date, index: true

      t.datetime :hidden_at, index: true

      t.timestamps null: false
    end
  end
end
