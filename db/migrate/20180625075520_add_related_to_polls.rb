class AddRelatedToPolls < ActiveRecord::Migration[4.2]
  def change
    add_reference :polls, :related, index: true, polymorphic: true
  end
end
