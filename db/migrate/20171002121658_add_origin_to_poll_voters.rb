class AddOriginToPollVoters < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_voters, :origin, :string
  end
end
