class SpendingProposal < ActiveRecord::Base
  include Measurable
  include Sanitizable
  include Taggable

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  validates :title, presence: true
  validates :author, presence: true
  validates :description, presence: true

  validates :title, length: { in: 4..Proposal.title_max_length }
  validates :description, length: { maximum: Proposal.description_max_length }

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create
end
