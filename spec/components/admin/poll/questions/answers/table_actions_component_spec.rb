require "rails_helper"

describe Admin::Poll::Questions::Answers::TableActionsComponent, controller: Admin::BaseController do
  before { sign_in(create(:administrator).user) }

  it "displays the edit and destroy actions when the poll has not started" do
    answer = create(:poll_question_answer, poll: create(:poll, :future))

    render_inline Admin::Poll::Questions::Answers::TableActionsComponent.new(answer)

    expect(page).to have_link "Edit"
    expect(page).to have_button "Delete"
  end

  it "does not display the edit and destroy actions when the poll has started" do
    answer = create(:poll_question_answer, poll: create(:poll))

    render_inline Admin::Poll::Questions::Answers::TableActionsComponent.new(answer)

    expect(page).not_to have_link "Edit"
    expect(page).not_to have_button "Delete"
  end
end
