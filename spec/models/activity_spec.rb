require "rails_helper"

describe Activity do
  it "is valid for different actionables" do
    expect(build(:activity, actionable: create(:proposal))).to be_valid
    expect(build(:activity, actionable: create(:debate))).to be_valid
    expect(build(:activity, actionable: create(:comment))).to be_valid
    expect(build(:activity, actionable: create(:user))).to be_valid
    expect(build(:activity, actionable: create(:newsletter))).to be_valid
  end

  it "is a valid only with allowed actions" do
    expect(build(:activity, action: "hide")).to be_valid
    expect(build(:activity, action: "block")).to be_valid
    expect(build(:activity, action: "restore")).to be_valid
    expect(build(:activity, action: "email")).to be_valid
    expect(build(:activity, action: "dissapear")).not_to be_valid
  end

  it "dynamically validates valid actions" do
    stub_const("#{Activity}::VALID_ACTIONS", %w[custom])

    expect(build(:activity, action: "custom")).to be_valid
    expect(build(:activity, action: "hide")).not_to be_valid
  end

  describe "log" do
    it "creates an activity entry" do
      user = create(:user)
      proposal = create(:proposal)

      expect { Activity.log(user, :hide, proposal) }.to change { Activity.count }.by(1)

      activity = Activity.last
      expect(activity.user_id).to eq(user.id)
      expect(activity.action).to eq("hide")
      expect(activity.actionable).to eq(proposal)
    end
  end

  describe "on" do
    it "lists all activity on an actionable object" do
      proposal  = create(:proposal)
      activity1 = create(:activity, action: "hide", actionable: proposal)
      activity2 = create(:activity, action: "restore", actionable: proposal)
      activity3 = create(:activity, action: "hide", actionable: proposal)
      create(:activity, action: "restore", actionable: create(:debate))
      create(:activity, action: "hide", actionable: create(:proposal))
      create(:activity, action: "hide", actionable: create(:comment))
      create(:activity, action: "block", actionable: create(:user))

      expect(Activity.on(proposal)).to match_array [activity1, activity2, activity3]
    end
  end

  describe "by" do
    it "lists all activity of a user" do
      user1 = create(:user)
      activity1 = create(:activity, user: user1)
      activity2 = create(:activity, user: user1, action: "restore", actionable: create(:debate))
      activity3 = create(:activity, user: user1, action: "hide", actionable: create(:proposal))
      activity4 = create(:activity, user: user1, action: "hide", actionable: create(:comment))
      activity5 = create(:activity, user: user1, action: "block", actionable: create(:user))
      activity6 = create(:activity, user: user1, action: "valuate", actionable: create(:budget_investment))
      create_list(:activity, 3)

      expect(Activity.by(user1)).to match_array(
        [activity1, activity2, activity3, activity4, activity5, activity6]
      )
    end
  end

  describe "scopes by actionable" do
    it "filters by actionable type" do
      on_proposal   = create(:activity, actionable: create(:proposal))
      on_debate     = create(:activity, actionable: create(:debate))
      on_comment    = create(:activity, actionable: create(:comment))
      on_user       = create(:activity, actionable: create(:user))
      on_investment = create(:activity, actionable: create(:budget_investment))

      expect(Activity.on_proposals).to eq [on_proposal]
      expect(Activity.on_debates).to eq [on_debate]
      expect(Activity.on_comments).to eq [on_comment]
      expect(Activity.on_users).to eq [on_user]
      expect(Activity.on_budget_investments).to eq [on_investment]
    end
  end
end
