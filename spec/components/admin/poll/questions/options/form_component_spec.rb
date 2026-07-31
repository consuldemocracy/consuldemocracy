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
end
