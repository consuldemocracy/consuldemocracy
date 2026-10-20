require "rails_helper"

describe Shared::CommentsComponent do
  factories = [
    :budget_investment,
    :debate,
    :legislation_annotation,
    :legislation_question,
    :poll_with_author,
    :proposal,
    :topic_with_community,
    :topic_with_investment_community
  ]

  let(:factory) { factories.sample }
  let(:record) { create(factory) }
  let(:comment_tree) { CommentTree.new(record, nil, "most_voted") }

  before do
    allow_any_instance_of(Comments::CommentComponent).to receive(:comment_tree).and_return(comment_tree)
    allow_any_instance_of(Shared::OrderLinksComponent).to receive(:render?).and_return(false)
  end

  it "does not show hidden comments between a root and its reply" do
    root = create(:comment, commentable: record, body: "Root comment")
    middle = create(:comment, commentable: record, parent: root, body: "Hidden middle")
    create(:comment, commentable: record, parent: middle, body: "Visible reply")
    middle.hide

    render_inline Shared::CommentsComponent.new(record, comment_tree)

    expect(page).to have_content "Root comment"
    expect(page).to have_content "This comment has been deleted"
    expect(page).to have_content "Visible reply"
    expect(page).not_to have_content "Hidden middle"
  end
end
