class CreateProbes < ActiveRecord::Migration
  def change
    create_table :probes do |t|
      t.string :codename
      t.boolean :voting_allowed, default: true
    end

    add_index :probes, :codename
  end
end
