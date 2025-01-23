require "rails_helper"

describe Layout::CookiesConsent::SwitchComponent do
  let(:component) do
    Layout::CookiesConsent::SwitchComponent.new(
      "cookie_name",
      label: "Accept Cookies",
      description: "Enable or disable cookies for the site."
    )
  end

  it "renders the switch component with the correct label and description" do
    render_inline(component)

    expect(page).to have_css ".name", text: "Accept Cookies"
    expect(page).to have_css ".description", text: "Enable or disable cookies for the site."
    expect(page).to have_css "input.switch-input[type='checkbox'][name='cookie_name']"
    expect(page).not_to have_css "[type='checkbox'][checked]"
    expect(page).not_to have_css "[type='checkbox'][disabled]"
  end

  it "renders the checkbox as checked when `checked` is true" do
    render_inline(
      Layout::CookiesConsent::SwitchComponent.new(
        "cookie_name",
        label: "Accept Cookies",
        description: "Enable or disable cookies for the site.",
        checked: true
      )
    )

    expect(page).to have_css "input[type='checkbox'][checked]"
  end

  it "renders the checkbox as disabled when `disabled` is true" do
    render_inline(
      Layout::CookiesConsent::SwitchComponent.new(
        "cookie_name",
        label: "Accept Cookies",
        description: "Enable or disable cookies for the site.",
        disabled: true
      )
    )

    expect(page).to have_css "input[type='checkbox'][disabled]"
  end

  it "renders the correct accessibility elements" do
    render_inline(component)

    expect(page).to have_field "Accept Cookies"
    expect(page).to have_css "[aria-hidden]", exact_text: "Yes"
    expect(page).to have_css "[aria-hidden]", exact_text: "No"
  end

  it "renders the yes and no states for the switch" do
    render_inline(component)

    expect(page).to have_css ".switch-active", text: "Yes"
    expect(page).to have_css ".switch-inactive", text: "No"
  end
end
