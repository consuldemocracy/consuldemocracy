class AddTokenToPollVoters < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_voters, :token, :string
  end
end
