class Legislation::Annotation < ActiveRecord::Base
  serialize :ranges, Array

  belongs_to :draft_version, class_name: 'Legislation::DraftVersion', foreign_key: 'legislation_draft_version_id'
  belongs_to :user
end
