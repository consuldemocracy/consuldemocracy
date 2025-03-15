require "rails_helper"

describe Officing::ResidenceController do
  describe "POST create" do
    it "creates a failed census called when the census data is invalid" do
      officer = create(:poll_officer)
      create(:poll_officer_assignment, officer: officer)

      sign_in(officer.user)

      expect do
        post :create, params: {
          residence: { document_type: "1", document_number: "23456789A", year_of_birth: "1980" }
        }
      end.to change { FailedCensusCall.count }.by(1)

      failed_census_call = FailedCensusCall.last
      expect(failed_census_call.poll_officer).to eq officer
      expect(officer.failed_census_calls).to eq [failed_census_call]
    end
  end
end
