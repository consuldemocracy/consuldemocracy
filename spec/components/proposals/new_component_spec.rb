require "rails_helper"

describe Proposals::NewComponent do
  before { sign_in(create(:user)) }
  let(:proposal) { build(:proposal) }

  describe "header" do
    it "contains a link to open the help page in a new window" do
      render_inline Proposals::NewComponent.new(proposal)

      page.find("header") do |header|
        expect(header).to have_css "a[target=_blank]", exact_text: "How do citizen proposals work?"
      end
    end
  end
end
