class RemoveAuthorIdFromPolls < ActiveRecord::Migration
  def change
    remove_column :polls, :author_id, :integer
  end
end
