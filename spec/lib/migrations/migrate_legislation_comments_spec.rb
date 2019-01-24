require 'rails_helper'
require 'migrations/legislation_comments_migration'

describe LegislationCommentsMigration do

  let!(:legislation_comments_migration) { LegislationCommentsMigration.new }

  let!(:debate)   { create(:debate) }
  let!(:process)  { create(:legislation_process, :in_debate_phase) }
  let!(:question) { create(:legislation_question, process: process) }

  before do
    allow_any_instance_of(LegislationCommentsMigration).
    to receive(:old_debates).
    and_return([debate.id])

    allow_any_instance_of(LegislationCommentsMigration).
    to receive(:new_questions).
    and_return([question.id])
  end

  it "migrates comments from a debate to a legislation question" do
    4.times { create(:comment, commentable: debate) }

    legislation_comments_migration.migrate_data

    expect(Debate.first.comments.count).to eq(0)
    expect(Legislation::Question.first.comments.count).to eq(4)
  end

  it "resets comment counters" do
    4.times { create(:comment, commentable: debate) }

    legislation_comments_migration.migrate_data

    expect(Debate.first.comments_count).to eq(0)
    expect(Legislation::Question.first.comments_count).to eq(4)
  end

  it "maintains comment data" do
    create(:comment, commentable: debate, body: "First comment")

    legislation_comments_migration.migrate_data

    comment = question.comments.first
    expect(comment.body).to eq("First comment")
  end

  it "maintains first level replies" do
    comment = create(:comment, commentable: debate)
    reply = create(:comment,
                    commentable: debate,
                    parent: comment)

    legislation_comments_migration.migrate_data

    comments = question.comments
    expect(comment.children.count).to eq(1)
  end

  it "maintains second level replies" do
    comment = create(:comment, commentable: debate)

    first_reply = create(:comment,
                          commentable: debate,
                          parent: comment)

    reply_to_first_reply = create(:comment,
                                   commentable: debate,
                                   parent: first_reply)

    legislation_comments_migration.migrate_data

    comments = question.comments.first
    expect(first_reply.children.count).to eq(1)
  end

  it "maintains comment author" do
    author = create(:user)
    comment = create(:comment, commentable: debate, author: author)

    legislation_comments_migration.migrate_data
    expect(comment.author).to eq(author)
  end

  it "maintains comment votes" do
    comment = create(:comment, commentable: debate)
    create(:vote, votable: comment)

    legislation_comments_migration.migrate_data
    expect(comment.votes_for.count).to eq(1)
  end

end
