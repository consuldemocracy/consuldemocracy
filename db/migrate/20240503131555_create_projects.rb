class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :slug, null: false
      t.integer :state, default: 0, null: false

      t.timestamps
      t.index :state
    end

    create_table :project_translations do |t|
      t.bigint :project_id, null: false
      t.string :locale, null: false
      t.string :title
      t.text :teaser
      t.text :content
      t.timestamps null: false

      t.index :locale
      t.index :project_id
    end

    create_table :project_phases do |t|
      t.references :project
      t.integer :order, default: 1, null: false
      t.boolean :enabled, default: true
      t.datetime :starts_at, index: true
      t.datetime :ends_at, index: true

      t.timestamps
      t.index :order
      t.index :enabled
    end

    create_table :project_phase_translations do |t|
      t.bigint :project_phase_id, null: false
      t.string :locale, null: false
      t.string :title
      t.string :title_short
      t.text :content
      t.timestamps null: false

      t.index :locale
      t.index :project_phase_id
    end

  end
end
