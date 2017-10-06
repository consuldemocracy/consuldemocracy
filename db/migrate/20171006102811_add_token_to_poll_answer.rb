class AddTokenToPollAnswer < ActiveRecord::Migration
  def change
    add_column :poll_answers, :token, :string
  end
end
