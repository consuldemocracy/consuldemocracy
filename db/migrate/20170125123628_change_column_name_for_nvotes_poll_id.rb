class ChangeColumnNameForNvotesPollId < ActiveRecord::Migration
  def change
    remove_column :nvotes, :agora_id
    add_column :nvotes, :nvotes_poll_id, :string
  end
end
