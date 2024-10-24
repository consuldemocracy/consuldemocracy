require "rails_helper"

describe Shared::CommentsCountComponent do
  it "renders a link when a URL is given" do
    render_inline Shared::CommentsCountComponent.new(0, url: "http://www.url.com")

    expect(page.find(".comments-count")).to have_content "No comments"
    expect(page.find(".comments-count")).to have_link "No comments", href: "http://www.url.com"
  end

  it "renders plain text when no URL is given" do
    render_inline Shared::CommentsCountComponent.new(1)

    expect(page.find(".comments-count")).to have_content "1 comment"
    expect(page.find(".comments-count")).not_to have_link "1 comment"
  end
end
