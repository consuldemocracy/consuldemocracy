require "rails_helper"

describe Types::MilestoneType do
  it "formats publication date like in view" do
    milestone = create(:milestone, publication_date: Time.zone.parse("2024-07-02 11:45:17"))

    response = execute("{ milestone(id: #{milestone.id}) { id publication_date } }")
    received_publication_date = dig(response, "data.milestone.publication_date")
    expect(received_publication_date).to eq "2024-07-02"
  end
end
