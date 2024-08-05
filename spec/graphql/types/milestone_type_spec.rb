require "rails_helper"

describe Types::MilestoneType do
  it "formats publication date like in view" do
    milestone = create(:milestone, publication_date: Time.zone.parse("2024-07-02 11:45:17"))

    response = execute("{ milestone(id: #{milestone.id}) { id date_of_publication } }")
    received_date_of_publication = dig(response, "data.milestone.date_of_publication")
    expect(received_date_of_publication).to eq "2024-07-02"
  end
end
