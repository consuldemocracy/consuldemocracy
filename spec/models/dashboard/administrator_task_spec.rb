require "rails_helper"

describe Dashboard::AdministratorTask do
  it "is invalid when source is nil" do
    task = build(:dashboard_administrator_task, source: nil)
    expect(task).not_to be_valid
  end
end
