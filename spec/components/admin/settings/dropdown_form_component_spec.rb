require "rails_helper"

describe Admin::Settings::DropdownFormComponent do
  let(:setting) { create(:setting) }
  let(:options) { [["Option 1", "option1"], ["Option 2", "option2"], ["Option 3", "option3"]] }
  let(:component) { Admin::Settings::DropdownFormComponent.new(setting, options: options) }

  it "renders a dropdown" do
    render_inline component

    expect(page).to have_css "form.dropdown-settings-form"
    expect(page).to have_select id: "value_setting_#{setting.id}",
                                options: ["None", "Option 1", "Option 2", "Option 3"]
    expect(page).to have_button "Update"
  end

  it "includes accessibility attributes on the dropdown" do
    render_inline component

    expect(page).to have_css "select[aria-labelledby='title_setting_#{setting.id}']"
    expect(page).to have_css "select[aria-describedby='description_setting_#{setting.id}']"
  end

  describe "tab parameter" do
    it "renders a hidden tab field when tab is provided" do
      render_inline Admin::Settings::DropdownFormComponent.new(setting, options: options, tab: "a-tab")

      expect(page).to have_field "tab", type: :hidden, with: "a-tab"
    end

    it "does not render a hidden tab field when tab is not provided" do
      render_inline component

      expect(page).not_to have_field "tab", type: :hidden
    end
  end

  describe "disabled parameter" do
    it "renders an enabled fieldset and button by default" do
      render_inline component

      expect(page).not_to have_css "fieldset[disabled]"
      expect(page).to have_button "Update", disabled: false
    end

    it "renders a disabled fieldset when disabled is true" do
      render_inline Admin::Settings::DropdownFormComponent.new(setting, options: options, disabled: true)

      expect(page).to have_css "fieldset[disabled]"
      expect(page).to have_button "Update", disabled: true
    end
  end

  describe "selected value" do
    it "selects the current setting value when set" do
      setting.update!(value: "option2")

      render_inline component

      expect(page).to have_select id: "value_setting_#{setting.id}", selected: "Option 2"
    end

    it "has blank option available when value is not set" do
      setting.update!(value: "")

      render_inline component

      expect(page).to have_select id: "value_setting_#{setting.id}",
                                  options: ["None", "Option 1", "Option 2", "Option 3"]
      expect(page.find("#value_setting_#{setting.id}").value).to eq("")
    end
  end
end
