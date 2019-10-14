class AddsIndexes < ActiveRecord::Migration
  def change
    add_index :debates, :author_id
    add_index :debates, [:author_id, :hidden_at]

    add_index :proposals, :author_id
    add_index :proposals, [:author_id, :hidden_at]
    add_index :proposals, :cached_votes_up
    add_index :proposals, :confidence_score
    add_index :proposals, :hidden_at
    add_index :proposals, :hot_score

    add_index :settings, :key

    add_index :verified_users, :document_number
    add_index :verified_users, :phone
    add_index :verified_users, :email
  end
end
