require "rails_helper"

describe "users:remove_duplicate_users" do
  before { Rake::Task["users:remove_duplicate_users"].reenable }

  it "deletes duplicate users" do
    user = create_user_with_document
    2.times { create_user_with_document }
    other_document = create_user_with_document(document_number: "87654321Z")
    no_document = create(:user)

    Rake.application.invoke_task("users:remove_duplicate_users")

    expect(User.where(document_number: "12345678Z").ids).to eq [user.id]
    expect(User.where(document_number: "87654321Z").ids).to eq [other_document.id]
    expect(User.where(id: no_document.id).count).to eq 1
    expect(User.count).to eq 3
    expect(User.with_hidden.count).to eq 5
  end

  it "keeps the oldest user per document" do
    user = create_user_with_document
    create_user_with_document

    Rake.application.invoke_task("users:remove_duplicate_users")

    expect(User.where(document_number: "12345678Z").ids).to eq [user.id]
    expect(User.count).to eq 1
  end

  it "keeps a not-erased user over an older erased user" do
    create_user_with_document(erased_at: Time.current)
    user = create_user_with_document

    Rake.application.invoke_task("users:remove_duplicate_users")

    expect(User.where(document_number: "12345678Z").ids).to eq [user.id]
    expect(User.count).to eq 1
  end

  it "removes duplicate users on tenants" do
    create(:tenant, schema: "duplicate")
    user = Tenant.switch("duplicate") { create_user_with_document }
    Tenant.switch("duplicate") { create_user_with_document }

    Rake.application.invoke_task("users:remove_duplicate_users")

    Tenant.switch("duplicate") do
      expect(User.where(document_number: "12345678Z").ids).to eq [user.id]
      expect(User.count).to eq 1
    end
  end

  it "reassigns votes, ballots, poll voters, signatures and failed census calls" do
    user = create_user_with_document
    duplicate = create_user_with_document

    debate = create(:debate)
    create(:vote, votable: debate, voter: duplicate)
    create(:budget_ballot, user: duplicate)
    create(:poll_voter, user: duplicate)
    create(:signature, user: duplicate)
    create(:failed_census_call, user: duplicate)

    Rake.application.invoke_task("users:remove_duplicate_users")

    expect(debate.reload.cached_votes_up).to eq 1
    expect(Vote.where(voter: user, votable: debate).count).to eq 1
    expect(Budget::Ballot.where(user: user).count).to eq 1
    expect(Poll::Voter.where(user: user).count).to eq 1
    expect(Signature.where(user: user).count).to eq 1
    expect(FailedCensusCall.where(user: user).count).to eq 1
    expect(user.reload.failed_census_calls_count).to eq 1
  end

  it "keeps a single vote when both users voted on the same votable" do
    user = create_user_with_document
    duplicate = create_user_with_document

    debate = create(:debate)
    create(:vote, votable: debate, voter: user)
    create(:vote, votable: debate, voter: duplicate)

    Rake.application.invoke_task("users:remove_duplicate_users")

    expect(Vote.where(votable: debate).count).to eq 1
    expect(Vote.where(votable: debate, voter: user).count).to eq 1
    expect(Vote.count).to eq 1
    expect(debate.reload.cached_votes_up).to eq 1
  end

  it "reassigns authored content" do
    user = create_user_with_document
    duplicate = create_user_with_document

    debate = create(:debate, author: duplicate)
    proposal = create(:proposal, author: duplicate)
    comment = create(:comment, user: duplicate)
    investment = create(:budget_investment, author: duplicate)
    follow = create(:follow, user: duplicate, followable: debate)

    Rake.application.invoke_task("users:remove_duplicate_users")

    expect(debate.reload.author_id).to eq user.id
    expect(proposal.reload.author_id).to eq user.id
    expect(comment.reload.user_id).to eq user.id
    expect(investment.reload.author_id).to eq user.id
    expect(follow.reload.user_id).to eq user.id
  end

  it "reassigns followable and actionable to the duplicate user" do
    user = create_user_with_document
    duplicate = create_user_with_document
    user3 = create(:user)

    follow = create(:follow, user: user3, followable: duplicate)
    activity = Activity.log(user3, :hide, duplicate)

    Rake.application.invoke_task("users:remove_duplicate_users")

    expect(follow.reload.followable_id).to eq user.id
    expect(activity.reload.actionable_id).to eq user.id
  end

  it "reassigns roles when the user doesn't have them" do
    user = create_user_with_document
    duplicate = create_user_with_document

    valuator = create(:valuator, user: duplicate)
    moderator = create(:moderator, user: duplicate)
    officer = create(:poll_officer, user: duplicate)

    Rake.application.invoke_task("users:remove_duplicate_users")

    expect(Valuator.where(user: user).ids).to eq [valuator.id]
    expect(Moderator.where(user: user).ids).to eq [moderator.id]
    expect(Poll::Officer.where(user: user).ids).to eq [officer.id]
  end

  it "merges role associations when both users have the same role" do
    user = create_user_with_document
    duplicate = create_user_with_document

    valuator = create(:valuator, user: user)
    duplicate_valuator = create(:valuator, user: duplicate)
    budget = create(:budget)
    shared_budget = create(:budget)
    BudgetValuator.create!(budget: shared_budget, valuator: valuator)
    BudgetValuator.create!(budget: shared_budget, valuator: duplicate_valuator)
    BudgetValuator.create!(budget: budget, valuator: duplicate_valuator)
    investment = create(:budget_investment)
    Budget::ValuatorAssignment.create!(investment: investment, valuator: duplicate_valuator)

    Rake.application.invoke_task("users:remove_duplicate_users")

    expect(Valuator.where(user: user).ids).to eq [valuator.id]
    expect(BudgetValuator.where(budget: shared_budget).pluck(:valuator_id)).to eq [valuator.id]
    expect(BudgetValuator.where(budget: budget).pluck(:valuator_id)).to eq [valuator.id]
    valuator_assignments = Budget::ValuatorAssignment.where(investment: investment)
    expect(valuator_assignments.pluck(:valuator_id)).to eq [valuator.id]
    expect(valuator.reload.budget_investments_count).to eq 1
    expect(investment.reload.valuator_assignments_count).to eq 1
  end

  it "merges moderator comments when both users are moderators" do
    user = create_user_with_document
    duplicate = create_user_with_document

    moderator = create(:moderator, user: user)
    duplicate_moderator = create(:moderator, user: duplicate)
    comment = create(:comment, moderator_id: duplicate_moderator.id)

    Rake.application.invoke_task("users:remove_duplicate_users")

    expect(Moderator.where(user: user).ids).to eq [moderator.id]
    expect(comment.reload.moderator_id).to eq moderator.id
  end

  it "reassigns the duplicate's identities and deletes conflicting ones" do
    user = create_user_with_document
    duplicate = create_user_with_document

    create(:identity, user: user, provider: "Twitter", uid: "123")
    Identity.insert!({
      user_id: duplicate.id,
      provider: "Twitter",
      uid: "123",
      created_at: Time.current,
      updated_at: Time.current
    })
    unique_identity = create(:identity, user: duplicate, provider: "Google", uid: "456")

    Rake.application.invoke_task("users:remove_duplicate_users")

    shared_identities = Identity.where(provider: "Twitter", uid: "123")
    expect(shared_identities.count).to eq 1
    expect(shared_identities.first.user_id).to eq user.id
    expect(Identity.find(unique_identity.id).user_id).to eq user.id
  end

  it "logs the deleted user in the kept user's data log" do
    user = create_user_with_document
    duplicate = create_user_with_document

    Rake.application.invoke_task("users:remove_duplicate_users")

    expect(user.reload.former_users_data_log).to include("id: #{duplicate.id}")
  end

  def create_user_with_document(document_number: "12345678Z", document_type: "1", **attributes)
    create(:user, **attributes).tap do |user|
      user.update_columns(document_number: document_number, document_type: document_type)
    end
  end
end
