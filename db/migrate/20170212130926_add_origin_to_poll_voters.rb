class AddOriginToPollVoters < ActiveRecord::Migration
  def change
    add_column :poll_voters, :origin, :string
  end
end
