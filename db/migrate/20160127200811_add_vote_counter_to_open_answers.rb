class AddVoteCounterToOpenAnswers < ActiveRecord::Migration
  def change
    add_column :open_answers, :cached_votes_total, :integer, default: 0
    add_column :open_answers, :cached_votes_up,    :integer, default: 0
    add_column :open_answers, :cached_votes_down,  :integer, default: 0
  end
end
