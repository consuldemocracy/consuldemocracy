require "rails_helper"

describe Admin::Poll::Questions::Options::FormComponent do
  let(:question) { create(:poll_question) }
  let(:option) { build(:poll_question_option, question: question) }
  let(:component) { Admin::Poll::Questions::Options::FormComponent.new(option, url: "/") }

  it "renders the form" do
    render_inline component

    expect(page).to have_field "Answer"
    expect(page).to have_field "Description (optional)"
    expect(page).to have_button "Save"
  end

  describe "allows custom text checkbox" do
    it "includes accessibility attributes" do
      render_inline component

      checkbox = page.find_field("Allow custom text", type: :checkbox)
      help_id = checkbox[:"aria-describedby"]

      expect(help_id).to be_present
      expect(page).to have_css(
        "##{help_id}",
        text: "Allows users to write their own answer when selecting this option"
      )
    end
  end
end
