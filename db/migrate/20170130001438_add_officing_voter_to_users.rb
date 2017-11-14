class AddOfficingVoterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :officing_voter, :boolean, default: false
  end
end
