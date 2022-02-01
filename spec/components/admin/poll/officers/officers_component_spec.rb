require "rails_helper"

describe Admin::Poll::Officers::OfficersComponent, controller: Admin::BaseController do
  let(:existing_officer) { create(:poll_officer, name: "Old officer") }
  let(:new_officer) { build(:poll_officer, name: "New officer") }
  let(:officers) { [existing_officer, new_officer] }
  let(:component) { Admin::Poll::Officers::OfficersComponent.new(officers) }

  it "renders as many rows as officers" do
    render_inline component

    tbody = page.find("tbody")

    expect(tbody).to have_css "tr", count: 2
    expect(tbody).to have_button count: 2
  end

  it "renders button to destroy for existing officers" do
    render_inline component
    row = page.find("tr", text: "Old officer")

    expect(row).to have_button "Delete position"
    expect(row).to have_css "input[name='_method'][value='delete']", visible: :hidden
  end

  it "renders button to add for new officers" do
    render_inline component
    row = page.find("tr", text: "New officer")

    expect(row).to have_button "Add"
    expect(row).to have_css "form[method='post']"
    expect(row).not_to have_css "input[name='_method']", visible: :all
  end

  it "accepts table options" do
    render_inline Admin::Poll::Officers::OfficersComponent.new(officers, class: "my-officers-table")

    expect(page).to have_css "table.my-officers-table"
  end
end
