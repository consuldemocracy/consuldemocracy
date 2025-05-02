require "rails_helper"

describe Milestones::ProgressBarsComponent do
  let(:milestoneable) { create(:legislation_process) }

  it "is not rendered without a main progress bar" do
    create(:progress_bar, :secondary, progressable: milestoneable, title: "Defeat Evil Lords")

    render_inline Milestones::ProgressBarsComponent.new(milestoneable)

    expect(page).not_to be_rendered
  end

  it "renders a main progress bar" do
    create(:progress_bar, progressable: milestoneable)

    render_inline Milestones::ProgressBarsComponent.new(milestoneable)

    expect(page).to have_content "Progress"
    expect(page).to have_css "[role=progressbar]", count: 1
    expect(page).to have_css "[role=progressbar][aria-label='Progress']"
  end

  it "renders both main and secondary progress bars" do
    create(:progress_bar, progressable: milestoneable)
    create(:progress_bar, :secondary, progressable: milestoneable, title: "Build laboratory")

    render_inline Milestones::ProgressBarsComponent.new(milestoneable)

    expect(page).to have_content "Progress"
    expect(page).to have_content "Build laboratory"
    expect(page).to have_css "[role=progressbar]", count: 2
    expect(page).to have_css "[role=progressbar][aria-label='Progress']"
    expect(page).to have_css "[role=progressbar][aria-label='Build laboratory']"
  end
end
