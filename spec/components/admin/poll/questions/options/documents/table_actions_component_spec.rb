require "rails_helper"

describe Admin::Poll::Questions::Options::Documents::TableActionsComponent, :admin do
  let(:future_option) { create(:poll_question_option, poll: create(:poll, :future)) }
  let(:current_option) { create(:poll_question_option, poll: create(:poll)) }

  it "displays the destroy action when the poll has not started" do
    document = create(:document, documentable: future_option)

    render_inline Admin::Poll::Questions::Options::Documents::TableActionsComponent.new(document)

    expect(page).to have_link "Download file"
    expect(page).to have_button "Delete"
    expect(page).not_to have_link "Edit"
  end

  it "does not display the destroy action when the poll has started" do
    document = create(:document, documentable: current_option)

    render_inline Admin::Poll::Questions::Options::Documents::TableActionsComponent.new(document)

    expect(page).to have_link "Download file"
    expect(page).not_to have_button "Delete"
    expect(page).not_to have_link "Edit"
  end
end
