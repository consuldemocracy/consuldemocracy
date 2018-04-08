class AddTokenToPollVoters < ActiveRecord::Migration
  def change
    add_column :poll_voters, :token, :string
  end
end
