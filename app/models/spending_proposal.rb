class SpendingProposal < ActiveRecord::Base
  include Measurable
  include Sanitizable

  apply_simple_captcha

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  belongs_to :geozone

  validates :title, presence: true
  validates :author, presence: true
  validates :description, presence: true

  validates :title, length: { in: 4..SpendingProposal.title_max_length }
  validates :description, length: { maximum: SpendingProposal.description_max_length }

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create
end
