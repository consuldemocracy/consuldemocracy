require "rails_helper"

describe Admin::Poll::Questions::Options::Videos::TableActionsComponent, :admin do
  it "displays the edit and destroy actions when the poll has not started" do
    video = create(:poll_option_video, poll: create(:poll, :future))

    render_inline Admin::Poll::Questions::Options::Videos::TableActionsComponent.new(video)

    expect(page).to have_link "Edit"
    expect(page).to have_button "Delete"
  end

  it "does not display the edit and destroy actions when the poll has started" do
    video = create(:poll_option_video, poll: create(:poll))

    render_inline Admin::Poll::Questions::Options::Videos::TableActionsComponent.new(video)

    expect(page).not_to have_link "Edit"
    expect(page).not_to have_button "Delete"
  end
end
