class RemoveTokenFromPollVoter < ActiveRecord::Migration[6.0]
  def change
    remove_column :poll_voters, :token, :string
  end
end
