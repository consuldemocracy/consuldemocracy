class CreateDesignPhases < ActiveRecord::Migration
  def change
    create_table :design_phases do |t|
      t.string :name
      t.boolean :activated
      t.belongs_to :project, index: true, foreign_key: true

      t.timestamps
    end
  end
end
