# This migration comes from acts_as_taggable_on_engine (originally 2)
if ActiveRecord.gem_version >= Gem::Version.new("5.0")
  class AddMissingUniqueIndices < ActiveRecord::Migration[4.2]; end
else
  class AddMissingUniqueIndices < ActiveRecord::Migration; end
end
AddMissingUniqueIndices.class_eval do
  def self.up
    add_index :taggings,
              [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
              unique: true, name: "taggings_idx"
  end

  def self.down
    remove_index :taggings, name: "taggings_idx"
  end
end
