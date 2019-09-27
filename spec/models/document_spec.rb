require "rails_helper"

describe Document do

  it_behaves_like "document validations", "budget_investment_document"
  it_behaves_like "document validations", "proposal_document"

  context "scopes" do

    describe "#admin" do

      it "returns admin documents" do
        user_document = create(:document)
        admin_document1 = create(:document, :admin)
        admin_document2 = create(:document, :admin)
        admin_document3 = create(:document, :admin)

        expect(Document.admin).to match_array [admin_document1, admin_document2, admin_document3]
      end

    end
  end
end
