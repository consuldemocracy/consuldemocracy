require "rails_helper"

describe Document do
  it_behaves_like "document validations", "budget_investment_document"
  it_behaves_like "document validations", "proposal_document"

  it "stores attachments with both Paperclip and Active Storage" do
    document = create(:document, attachment: File.new("spec/fixtures/files/clippy.pdf"))

    expect(document.attachment).to exist
    expect(document.attachment_file_name).to eq "clippy.pdf"

    expect(document.storage_attachment).to be_attached
    expect(document.storage_attachment.filename).to eq "clippy.pdf"
  end

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
