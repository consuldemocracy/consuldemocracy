class AddRelatedToPolls < ActiveRecord::Migration
  def change
    add_reference :polls, :related, index: true, polymorphic: true
  end
end
