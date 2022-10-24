class AddsUserIdToPollVoters < ActiveRecord::Migration[4.2]
  def change
    add_reference :poll_voters, :user, index: true
  end
end
