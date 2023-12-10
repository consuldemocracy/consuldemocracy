require "rails_helper"

describe "Documents" do
  describe "Metadata" do
    scenario "download document without metadata" do
      login_as(create(:user))
      visit new_proposal_path

      fill_in "Proposal title", with: "debate"
      fill_in "Proposal summary", with: "In summary, what we want is..."
      fill_in "Full name of the person submitting the proposal", with: "Isabel Garcia"
      documentable_attach_new_file(file_fixture("logo_with_metadata.pdf"))
      check "I agree to the Privacy Policy and the Terms and conditions of use"

      click_button "Create proposal"

      io = URI.parse("#{app_host}#{polymorphic_path(Document.last.attachment)}").open
      reader = PDF::Reader.new(io)

      expect(reader.info[:Keywords]).not_to eq "Test Metadata"
      expect(reader.info[:Author]).not_to eq "Test Developer"
      expect(reader.info[:Title]).not_to eq "logo_with_metadata.pdf"
      expect(reader.info[:Producer]).not_to eq "Test Producer"
      expect(reader.info).to eq({})
    end
  end
end
