class RenameNvotesToPollNvotes < ActiveRecord::Migration
  def change
    rename_table :nvotes, :poll_nvotes
  end
end
