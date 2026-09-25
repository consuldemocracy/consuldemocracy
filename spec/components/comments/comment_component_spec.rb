require "rails_helper"

describe Comments::CommentComponent do
  let(:comment) { create(:comment) }
  let(:component) { Comments::CommentComponent.new(comment) }

  describe "comment-user element" do
    it "returns is-admin for comment done as administrator" do
      allow(comment).to receive(:as_administrator?).and_return true

      render_inline component

      expect(page).to have_css ".comment-user.is-admin"
    end

    it "returns is-moderator for comment done as moderator" do
      allow(comment).to receive(:as_moderator?).and_return true

      render_inline component

      expect(page).to have_css ".comment-user.is-moderator"
    end

    it "returns level followed by official level if user is official" do
      comment.user.update!(official_level: 1)

      render_inline component

      expect(page).to have_css ".comment-user.level-1"
    end

    it "returns is-author if the author is the commenting user" do
      comment.commentable.update!(author: comment.user)

      render_inline component

      expect(page).to have_css ".comment-user.is-author"
    end

    it "returns an empty class otherwise" do
      render_inline component

      expect(page.find(".comment-user")[:class].strip).to eq "comment-user"
    end
  end

  it "turns links into html links" do
    comment.update!(body: "Built with http://rubyonrails.org/")

    render_inline component

    expect(page).to have_content "Built with http://rubyonrails.org/"
    expect(page).to have_link "http://rubyonrails.org/", href: "http://rubyonrails.org/"
    expect(page.find_link("http://rubyonrails.org/")[:rel]).to eq("nofollow")
    expect(page.find_link("http://rubyonrails.org/")[:target]).to be_blank
  end
end
