require "rails_helper"

describe Admin::Poll::Questions::Answers::Documents::IndexComponent do
  before { sign_in(create(:administrator).user) }
  let(:future_answer) { create(:poll_question_answer, poll: create(:poll, :future)) }
  let(:current_answer) { create(:poll_question_answer, poll: create(:poll)) }

  it "displays the 'Add new document' link when the poll has not started" do
    render_inline Admin::Poll::Questions::Answers::Documents::IndexComponent.new(future_answer)

    expect(page).to have_link "Add new document"
  end

  it "does not display the 'Add new document' link when the poll has started" do
    render_inline Admin::Poll::Questions::Answers::Documents::IndexComponent.new(current_answer)

    expect(page).not_to have_link "Add new document"
  end
end
