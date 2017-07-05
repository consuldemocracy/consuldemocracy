class AddCallToActionToProblems < ActiveRecord::Migration
  def change
    add_column :problems, :call_to_action, :string
  end
end
