class CreateProbeSelections < ActiveRecord::Migration
  def change
    create_table :probe_selections do |t|
      t.belongs_to :probe
      t.belongs_to :probe_option
      t.belongs_to :user
    end

    add_index :probe_selections, :probe_id
    add_index :probe_selections, :user_id
    add_index :probe_selections, :probe_option_id
  end
end
