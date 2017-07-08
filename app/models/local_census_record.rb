class LocalCensusRecord < ActiveRecord::Base
  has_one :user

  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :date_of_birth, presence: true
  validates :postal_code, presence: true
end
