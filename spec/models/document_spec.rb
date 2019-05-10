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

        expect(Document.admin.count).to eq(3)
        expect(Document.admin).to include admin_document1
        expect(Document.admin).to include admin_document2
        expect(Document.admin).to include admin_document3
        expect(Document.admin).not_to include user_document
      end

    end
  end
end
