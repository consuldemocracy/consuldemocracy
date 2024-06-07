require "rails_helper"

describe Admin::Poll::Questions::Options::Documents::IndexComponent do
  before { sign_in(create(:administrator).user) }
  let(:future_option) { create(:poll_question_option, poll: create(:poll, :future)) }
  let(:current_option) { create(:poll_question_option, poll: create(:poll)) }

  it "displays the 'Add new document' link when the poll has not started" do
    render_inline Admin::Poll::Questions::Options::Documents::IndexComponent.new(future_option)

    expect(page).to have_link "Add new document"
  end

  it "does not display the 'Add new document' link when the poll has started" do
    render_inline Admin::Poll::Questions::Options::Documents::IndexComponent.new(current_option)

    expect(page).not_to have_link "Add new document"
  end
end
