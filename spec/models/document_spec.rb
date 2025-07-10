require "rails_helper"

describe Document do
  it_behaves_like "document validations", "budget_investment_document"
  it_behaves_like "document validations", "proposal_document"

  context "scopes" do
    describe "#admin" do
      it "returns admin documents" do
        admin_document = create(:document, :admin)

        expect(Document.admin).to eq [admin_document]
      end

      it "does not return user documents" do
        create(:document, admin: false)

        expect(Document.admin).to be_empty
      end
    end
  end
end
