require "rails_helper"

describe Admin::Poll::Officers::OfficersComponent, type: :component do
  let(:existing_officer) { create(:poll_officer, name: "Old officer") }
  let(:new_officer) { build(:poll_officer, name: "New officer") }
  let(:officers) { [existing_officer, new_officer] }
  let(:component) { Admin::Poll::Officers::OfficersComponent.new(officers) }

  it "renders as many rows as officers" do
    within "tbody" do
      expect(page).to have_css "tr", count: 2
      expect(page).to have_css "a", count: 2
    end
  end

  it "renders link to destroy for existing officers" do
    render_inline component
    row = page.find("tr", text: "Old officer")

    expect(row).to have_css "a[data-method='delete']", text: "Delete"
  end

  it "renders link to add for new officers" do
    render_inline component
    row = page.find("tr", text: "New officer")

    expect(row).to have_css "a[data-method='post']", text: "Add"
  end

  it "accepts table options" do
    render_inline Admin::Poll::Officers::OfficersComponent.new(officers, class: "my-officers-table")

    expect(page).to have_css "table.my-officers-table"
  end
end
