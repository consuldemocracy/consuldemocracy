class RenameRigthIdToRightId < ActiveRecord::Migration[5.0]
  def change
    rename_column :poll_pair_answers, :answer_rigth_id, :answer_right_id
  end
end
