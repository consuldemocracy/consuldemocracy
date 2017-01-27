class Poll
  class Voter < ActiveRecord::Base
    belongs_to :poll
    belongs_to :booth_assignment

    validates :poll, presence: true
    validates :document_number, presence: true, uniqueness: { scope: [:poll_id, :document_type], message: :has_voted }

    def census_api_response
      @census_api_response ||= CensusApi.new.call(document_type, document_number)
    end

    def in_census?
      census_api_response.valid?
    end

    def fill_stats_fields
      if in_census?
        self.gender = census_api_response.gender
        self.geozone_id = Geozone.select(:id).where(census_code: census_api_response.district_code).first.try(:id)
        self.age = voter_age(census_api_response.date_of_birth)
      end
    end

    def self.create_from_user(user, options = {})
      poll_id = options[:poll_id]
      booth_assignment_id = options[:booth_assignment_id]

      Voter.create(
        document_type: user.document_type,
        document_number: user.document_number,
        poll_id: poll_id,
        booth_assignment_id: booth_assignment_id,
        gender: user.gender,
        geozone_id: user.geozone_id,
        age: user.age
      )
    end

    private

      def voter_age(dob)
        if dob.blank?
          nil
        else
          now = Time.now.utc.to_date
          now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
        end
      end

  end
end