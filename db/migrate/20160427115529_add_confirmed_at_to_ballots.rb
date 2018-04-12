class AddConfirmedAtToBallots < ActiveRecord::Migration
  def change
    add_column :ballots, :confirmed_at, :datetime
  end
end
