require "rails_helper"

describe Shared::LinkListComponent do
  it "renders nothing with an empty list" do
    render_inline Shared::LinkListComponent.new

    expect(page).not_to be_rendered
  end

  it "returns nothing with a list of nil elements" do
    render_inline Shared::LinkListComponent.new(nil, nil)

    expect(page).not_to be_rendered
  end

  it "generates a list of links" do
    render_inline Shared::LinkListComponent.new(
      ["Home", "/"], ["Info", "/info"], class: "menu"
    )

    expect(page).to be_rendered with: '<ul class="menu">' + "\n" +
      '<li><a href="/">Home</a></li>' + "\n" +
      '<li><a href="/info">Info</a></li>' + "\n</ul>\n"
  end

  it "accepts anchor tags" do
    render_inline Shared::LinkListComponent.new(
      '<a href="/">Home</a>'.html_safe, ["Info", "/info"], class: "menu"
    )

    expect(page).to be_rendered with: '<ul class="menu">' + "\n" +
      '<li><a href="/">Home</a></li>' + "\n" +
      '<li><a href="/info">Info</a></li>' + "\n</ul>\n"
  end

  it "accepts options for links" do
    render_inline Shared::LinkListComponent.new(
      ["Home", "/", class: "root"], ["Info", "/info", id: "info"]
    )

    expect(page).to have_css "a", count: 2
    expect(page).to have_css "a.root", count: 1, exact_text: "Home"
    expect(page).to have_css "a#info", count: 1, exact_text: "Info"
  end

  it "ignores nil entries" do
    render_inline Shared::LinkListComponent.new(
      ["Home", "/", class: "root"], nil, ["Info", "/info", id: "info"]
    )

    expect(page).to have_css "li", count: 2
    expect(page).to have_css "a.root", count: 1, exact_text: "Home"
    expect(page).to have_css "a#info", count: 1, exact_text: "Info"
  end

  it "ignores empty entries" do
    render_inline Shared::LinkListComponent.new(
      ["Home", "/", class: "root"], "", ["Info", "/info", id: "info"]
    )

    expect(page).to have_css "li", count: 2
    expect(page).to have_css "a.root", count: 1, exact_text: "Home"
    expect(page).to have_css "a#info", count: 1, exact_text: "Info"
  end

  it "accepts an optional condition to check the active element" do
    render_inline Shared::LinkListComponent.new(
      ["Home", "/", false],
      ["Info", "/info", true],
      ["Help", "/help"]
    )

    expect(page).to have_css "li", count: 3
    expect(page).to have_css "li[aria-current='true']", count: 1, exact_text: "Info"
  end

  it "allows passing both the active condition and link options" do
    render_inline Shared::LinkListComponent.new(
      ["Home", "/", false, class: "root"],
      ["Info", "/info", true, id: "info"],
      ["Help", "/help", rel: "help"]
    )

    expect(page).to have_css "li", count: 3
    expect(page).to have_css "li[aria-current='true']", count: 1, exact_text: "Info"

    expect(page).to have_css "a.root", count: 1, exact_text: "Home"
    expect(page).to have_css "a#info", count: 1, exact_text: "Info"
    expect(page).to have_css "a[rel='help']", count: 1, exact_text: "Help"
  end
end
