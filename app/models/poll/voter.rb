class Poll
  class Voter < ActiveRecord::Base
    belongs_to :booth

    validate :in_census

    def in_census
      errors.add(:document_number, :not_in_census) unless census_api_response.valid?
    end

    def census_api_response
      CensusApi.new.call(document_type, document_number)
    end
  end
end