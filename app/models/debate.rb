class Debate < ActiveRecord::Base
  validates :title, presence: true
  validates :description, presence: true

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create
end
