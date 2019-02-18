require "rails_helper"

describe GraphQL::QueryTypeCreator do
  let(:api_type_definitions) do
    {
      ProposalNotification => { fields: { title: :string } },
      Proposal => { fields: { id: :integer, title: :string } }
    }
  end
  let(:api_types) { GraphQL::ApiTypesCreator.create(api_type_definitions) }

  describe "::create" do
    let(:query_type) { described_class.create(api_types) }

    it "creates a QueryType with fields to retrieve single objects whose model fields included an ID" do
      field = query_type.fields["proposal"]

      expect(field).to be_a(GraphQL::Field)
      expect(field.type).to eq(api_types[Proposal])
      expect(field.name).to eq("proposal")
    end

    it "creates a QueryType without fields to retrieve single objects whose model fields did not include an ID" do
      expect(query_type.fields["proposal_notification"]).to be_nil
    end

    it "creates a QueryType with connections to retrieve collections of objects" do
      connection = query_type.fields["proposals"]

      expect(connection).to be_a(GraphQL::Field)
      expect(connection.type).to eq(api_types[Proposal].connection_type)
      expect(connection.name).to eq("proposals")
    end
  end
end
