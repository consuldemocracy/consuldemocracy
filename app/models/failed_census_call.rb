class FailedCensusCall < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :poll_officer, class_name: "Poll::Officer", counter_cache: true
end

# == Schema Information
#
# Table name: failed_census_calls
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  document_number :string
#  document_type   :string
#  date_of_birth   :date
#  postal_code     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  district_code   :string
#  poll_officer_id :integer
#  year_of_birth   :integer
#
