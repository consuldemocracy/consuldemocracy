class AddTimestampsAndRemoveDateToPollPartialResult < ActiveRecord::Migration
  def self.up
    change_table :poll_partial_results do |t|
      t.remove :date
      t.datetime :created_at
      t.index [:booth_assignment_id, :created_at],
              # Custom name required to avoid index name length limit error
              name: 'index_poll_partial_results_on_booth_assignment_and_date'
    end
  end

  def self.down
    change_table :poll_partial_results do |t|
      t.remove :created_at
      t.date :date
      t.index [:booth_assignment_id, :date]
    end
  end
end
