require "rails_helper"

describe Shared::DateOfBirthFieldComponent do
  before do
    dummy_model = Class.new do
      include ActiveModel::Model
      attr_accessor :date_of_birth
    end

    stub_const("DummyModel", dummy_model)
  end

  let(:form) { ConsulFormBuilder.new(:dummy, DummyModel.new, ApplicationController.new.view_context, {}) }
  let(:component) { Shared::DateOfBirthFieldComponent.new(form) }

  it "uses the minimum required age as the latest date by default" do
    Setting["min_age_to_participate"] = 13

    travel_to "2015-07-15" do
      render_inline component

      expect(page).to have_field "Date of birth"
      expect(page).to have_css "input[type=date][min='1900-01-01'][max='2002-07-15']"
    end
  end
end
