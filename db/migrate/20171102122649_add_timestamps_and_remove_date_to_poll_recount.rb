class AddTimestampsAndRemoveDateToPollRecount < ActiveRecord::Migration
  def self.up
    change_table :poll_recounts do |t|
      t.remove :date
      t.datetime :created_at
    end
  end

  def self.down
    change_table :poll_recounts do |t|
      t.remove :created_at
      t.date :date
    end
  end
end
