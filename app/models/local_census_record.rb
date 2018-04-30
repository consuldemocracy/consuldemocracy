class LocalCensusRecord < ActiveRecord::Base
  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :date_of_birth, presence: true
  validates :postal_code, presence: true
end

# == Schema Information
#
# Table name: local_census_records
#
#  id              :integer          not null, primary key
#  document_number :string           not null
#  document_type   :string           not null
#  date_of_birth   :date             not null
#  postal_code     :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
