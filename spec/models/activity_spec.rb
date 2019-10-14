require 'rails_helper'

describe Activity do

  it "should be valid for different actionables" do
    expect(build(:activity, actionable: create(:proposal))).to be_valid
    expect(build(:activity, actionable: create(:debate))).to be_valid
    expect(build(:activity, actionable: create(:comment))).to be_valid
    expect(build(:activity, actionable: create(:user))).to be_valid
  end

  it "should be a valid only with allowed actions" do
    expect(build(:activity, action: "hide")).to be_valid
    expect(build(:activity, action: "block")).to be_valid
    expect(build(:activity, action: "restore")).to be_valid
    expect(build(:activity, action: "dissapear")).to_not be_valid
  end

  describe "log" do
    it "should create an activity entry" do
      user = create(:user)
      proposal = create(:proposal)

      expect{ Activity.log(user, :hide, proposal) }.to change { Activity.count }.by(1)

      activity = Activity.last
      expect(activity.user_id).to eq(user.id)
      expect(activity.action).to eq("hide")
      expect(activity.actionable).to eq(proposal)
    end
  end

  describe "on" do
    it "should list all activity on an actionable object" do
      proposal  = create(:proposal)
      activity1 = create(:activity, action: "hide", actionable: proposal)
      activity2 = create(:activity, action: "restore", actionable: proposal)
      activity3 = create(:activity, action: "hide", actionable: proposal)
      create(:activity, action: "restore", actionable: create(:debate))
      create(:activity, action: "hide", actionable: create(:proposal))
      create(:activity, action: "hide", actionable: create(:comment))
      create(:activity, action: "block", actionable: create(:user))

      expect(Activity.on(proposal).size).to eq 3
      [activity1, activity2, activity3].each do |a|
        expect(Activity.on(proposal)).to include(a)
      end
    end
  end

  describe "by" do
    it "should list all activity of a user" do
      user1 = create(:user)
      activity1 = create(:activity, user: user1)
      activity2 = create(:activity, user: user1, action: "restore", actionable: create(:debate))
      activity3 = create(:activity, user: user1, action: "hide", actionable: create(:proposal))
      activity4 = create(:activity, user: user1, action: "hide", actionable: create(:comment))
      activity5 = create(:activity, user: user1, action: "block", actionable: create(:user))
      activity6 = create(:activity, user: user1, action: "valuate", actionable: create(:budget_investment))
      create_list(:activity, 3)

      expect(Activity.by(user1).size).to eq 6

      [activity1, activity2, activity3, activity4, activity5, activity6].each do |a|
        expect(Activity.by(user1)).to include(a)
      end
    end
  end

  describe "scopes by actionable" do
    it "should filter by actionable type" do
      on_proposal   = create(:activity, actionable: create(:proposal))
      on_debate     = create(:activity, actionable: create(:debate))
      on_comment    = create(:activity, actionable: create(:comment))
      on_user       = create(:activity, actionable: create(:user))
      on_investment = create(:activity, actionable: create(:budget_investment))

      expect(Activity.on_proposals.size).to eq 1
      expect(Activity.on_debates.size).to eq 1
      expect(Activity.on_comments.size).to eq 1
      expect(Activity.on_users.size).to eq 1
      expect(Activity.on_budget_investments.size).to eq 1

      expect(Activity.on_proposals.first).to eq on_proposal
      expect(Activity.on_debates.first).to eq on_debate
      expect(Activity.on_comments.first).to eq on_comment
      expect(Activity.on_users.first).to eq on_user
      expect(Activity.on_budget_investments.first).to eq on_investment
    end
  end

end
