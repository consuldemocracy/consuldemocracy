class AddsUserIdToPollVoters < ActiveRecord::Migration
  def change
    add_reference :poll_voters, :user, index: true
  end
end
