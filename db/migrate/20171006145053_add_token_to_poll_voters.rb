class AddTokenToPollVoters < ActiveRecord::Migration
  def change
    add_column :poll_voters, :token, :string
    add_column :poll_voters, :token_seen_at, :date
  end
end
