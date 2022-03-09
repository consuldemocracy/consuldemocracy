require "rails_helper"

describe "shared errors" do
  before do
    dummy_model = Class.new do
      include ActiveModel::Model
      attr_accessor :title, :description, :days

      validates :title, presence: true
      validates :description, presence: true, length: { in: 10..100 }
      validates :days, numericality: { greater_than: 10 }
    end

    stub_const("DummyModel", dummy_model)
  end

  it "counts the number of fields with errors" do
    resource = DummyModel.new(title: "Present", description: "", days: 3)
    resource.valid?

    render "shared/errors", resource: resource

    expect(rendered).to have_content "2 errors"
  end

  it "doesn't include `base` errors in new records" do
    resource = build(:debate, title: "", description: "")
    resource.valid?

    render "shared/errors", resource: resource

    expect(rendered).to have_content "2 errors"
  end

  it "doesn't include `base` errors in existing records" do
    resource = create(:debate)
    resource.translations << Debate::Translation.new(title: "Title", description: "", locale: "es")
    resource.valid?

    render "shared/errors", resource: resource

    expect(rendered).to have_content "1 error"
  end
end
