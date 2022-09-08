require "rails_helper"

describe "rake db:calculate_tsv" do
  before { Rake::Task["db:calculate_tsv"].reenable }

  let :run_rake_task do
    Rake.application.invoke_task("db:calculate_tsv")
  end

  it "calculates the tsvector for comments, including hidden ones" do
    comment = create(:comment)
    hidden = create(:comment, :hidden)
    comment.update_column(:tsv, nil)
    hidden.update_column(:tsv, nil)

    expect(comment.reload.tsv).to be nil
    expect(hidden.reload.tsv).to be nil

    run_rake_task

    expect(comment.reload.tsv).not_to be nil
    expect(hidden.reload.tsv).not_to be nil
  end

  it "calculates the tsvector for proposal notifications, including hidden ones" do
    notification = create(:proposal_notification)
    hidden = create(:proposal_notification, :hidden)
    notification.update_column(:tsv, nil)
    hidden.update_column(:tsv, nil)

    expect(notification.reload.tsv).to be nil
    expect(hidden.reload.tsv).to be nil

    run_rake_task

    expect(notification.reload.tsv).not_to be nil
    expect(hidden.reload.tsv).not_to be nil
  end
end
