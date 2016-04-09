###
# CreateMentions class
#
# This class defines the create mentions migration in mention system
###
class CreateMentions < ActiveRecord::Migration
  ###
  # Changes the database
  ###
  def change
    ###
    # Mentions table creation
    ###
    create_table :mentions do |t|
      ###
      # Mentionee id field and mentionee type field definition
      ###
      t.references :mentionee, polymorphic: true

      ###
      # Mentioner id fiel and mentioner type field definition
      ###
      t.references :mentioner, polymorphic: true

      ###
      # Timestamps fields definition
      ###
      t.timestamps null: false
    end

    ###
    # Mentions table mentionee id field and mentionee type field index addition
    ###
    add_index :mentions, [:mentionee_id, :mentionee_type], name: "mentions_mentionee_idx"

    ###
    # Mentions table mentioner id field and mentioner type field index addition
    ###
    add_index :mentions, [:mentioner_id, :mentioner_type], name: "mentions_mentioner_idx"

    ###
    # Mentions table mentionee id field and mentionee type field and mentioner id field and mentioner type field unique index addition
    ###
    add_index :mentions, [:mentionee_id, :mentionee_type, :mentioner_id, :mentioner_type], name: "mentions_mentionee_mentioner_idx", unique: true
  end
end

