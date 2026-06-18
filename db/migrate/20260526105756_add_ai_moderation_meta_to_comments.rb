class AddAiModerationMetaToComments < ActiveRecord::Migration[7.2]
  def change
    add_column :comments, :ai_moderation_meta, :jsonb, default: {}
  end
end
