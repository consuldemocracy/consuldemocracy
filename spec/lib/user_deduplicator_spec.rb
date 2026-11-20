require "rails_helper"

describe UserDeduplicator do
  let(:user) { create(:user) }
  let(:duplicate_user) { create(:user) }

  describe "#deduplicate" do
    it "deletes the duplicate user and keeps the remaining user" do
      deduplicate

      expect(User.exists?(duplicate_user.id)).to be false
      expect(User.exists?(user.id)).to be true
    end

    it "appends the duplicate user to the remaining user's former_users_data_log" do
      deduplicate

      expect(user.reload.former_users_data_log).to include("id: #{duplicate_user.id}")
    end

    it "appends to an existing former_users_data_log" do
      user.update_column(:former_users_data_log, "id: 1 - 2026-01-01 12:00:00")

      deduplicate

      expect(user.reload.former_users_data_log).to include("id: 1")
      expect(user.reload.former_users_data_log).to include("| id: #{duplicate_user.id}")
    end
  end

  describe "votes" do
    let(:user) { create(:user, :level_three) }
    let(:duplicate_user) { create(:user, :level_three) }

    it "reassigns votes" do
      vote1 = create(:vote, voter: duplicate_user, votable: create(:debate))
      vote2 = create(:vote, voter: duplicate_user, votable: create(:proposal))
      vote3 = create(:vote, voter: duplicate_user, votable: create(:comment))

      create(:vote)

      deduplicate

      expect(Vote.where(voter: user).ids).to match_array [vote1.id, vote2.id, vote3.id]
      expect(Vote.where(voter_id: duplicate_user.id)).to be_empty
      expect(Vote.count).to eq 4
    end

    it "deletes the duplicate vote if the user has already voted on the same votable" do
      proposal = create(:proposal)
      create(:vote, voter: user, votable: proposal)
      create(:vote, voter: duplicate_user, votable: proposal)

      expect(proposal.reload.cached_votes_up).to eq 2

      deduplicate

      expect(proposal.reload.cached_votes_up).to eq 1
      expect(Vote.where(voter: user, votable: proposal).count).to eq 1
      expect(Vote.where(votable: proposal).count).to eq 1
    end

    it "reassigns budget ballots" do
      ballot1 = create(:budget_ballot, user: duplicate_user)
      ballot2 = create(:budget_ballot, user: duplicate_user)

      create(:budget_ballot)

      deduplicate

      expect(Budget::Ballot.where(user: user).ids).to match_array [ballot1.id, ballot2.id]
      expect(Budget::Ballot.where(user_id: duplicate_user.id)).to be_empty
      expect(Budget::Ballot.count).to eq 3
    end

    describe "poll voters" do
      it "reassigns poll voters" do
        voter1 = create(:poll_voter, user: duplicate_user)
        voter2 = create(:poll_voter, user: duplicate_user)

        create(:poll_voter)

        deduplicate

        expect(Poll::Voter.where(user: user).ids).to match_array [voter1.id, voter2.id]
        expect(Poll::Voter.where(user_id: duplicate_user.id)).to be_empty
        expect(Poll::Voter.count).to eq 3
      end

      it "deletes the duplicate poll voter if the user has already voted in the same poll" do
        poll = create(:poll)
        voter = create(:poll_voter, poll: poll, user: user)
        create(:poll_voter, poll: poll, user: duplicate_user)
        other_poll_voter = create(:poll_voter, poll: create(:poll), user: duplicate_user)

        deduplicate

        expect(Poll::Voter.where(user: user).ids).to match_array [voter.id, other_poll_voter.id]
        expect(Poll::Voter.where(user_id: duplicate_user.id)).to be_empty
        expect(Poll::Voter.count).to eq 2
      end
    end
  end

  it "reassigns debates, including hidden ones" do
    debate1 = create(:debate, author: duplicate_user)
    debate2 = create(:debate, :hidden, author: duplicate_user)

    create(:debate)

    deduplicate

    expect(Debate.with_hidden.where(author: user).ids).to match_array [debate1.id, debate2.id]
    expect(Debate.with_hidden.where(author_id: duplicate_user.id)).to be_empty
    expect(Debate.with_hidden.count).to eq 3
  end

  describe "proposals" do
    it "reassigns proposals, including hidden ones" do
      proposal1 = create(:proposal, author: duplicate_user)
      proposal2 = create(:proposal, :hidden, author: duplicate_user)

      create(:proposal)

      deduplicate

      expect(Proposal.with_hidden.where(author: user).ids).to match_array [proposal1.id, proposal2.id]
      expect(Proposal.with_hidden.where(author_id: duplicate_user.id)).to be_empty
      expect(Proposal.with_hidden.count).to eq 3
    end

    it "reassigns proposal notifications, including hidden ones" do
      proposal = create(:proposal, author: duplicate_user)

      notification1 = create(:proposal_notification, proposal: proposal)
      notification2 = create(:proposal_notification, :hidden, proposal: proposal)

      create(:proposal_notification)

      deduplicate

      expect(ProposalNotification.with_hidden.where(author: user).ids).to match_array(
        [notification1.id, notification2.id]
      )
      expect(ProposalNotification.with_hidden.where(author_id: duplicate_user.id)).to be_empty
      expect(ProposalNotification.with_hidden.count).to eq 3
    end
  end

  describe "budgets" do
    it "reassigns budget investments, including hidden ones" do
      investment1 = create(:budget_investment, author: duplicate_user)
      investment2 = create(:budget_investment, :hidden, author: duplicate_user)

      create(:budget_investment)

      deduplicate

      expect(Budget::Investment.with_hidden.where(author: user).ids).to match_array(
        [investment1.id, investment2.id]
      )
      expect(Budget::Investment.with_hidden.where(author_id: duplicate_user.id)).to be_empty
      expect(Budget::Investment.with_hidden.count).to eq 3
    end

    it "reassigns reclassified votes" do
      reclassified_vote = create(:budget_reclassified_vote, user: duplicate_user)

      create(:budget_reclassified_vote)

      deduplicate

      expect(Budget::ReclassifiedVote.where(user: user).ids).to eq [reclassified_vote.id]
      expect(Budget::ReclassifiedVote.where(user_id: duplicate_user.id)).to be_empty
      expect(Budget::ReclassifiedVote.count).to eq 2
    end
  end

  describe "signatures" do
    it "reassigns signature sheets" do
      signature_sheet = create(:signature_sheet, author: duplicate_user)

      create(:signature_sheet)

      deduplicate

      expect(SignatureSheet.where(author: user).ids).to eq [signature_sheet.id]
      expect(SignatureSheet.where(author_id: duplicate_user.id)).to be_empty
      expect(SignatureSheet.count).to eq 2
    end

    it "reassigns signatures" do
      signature = create(:signature, user: duplicate_user)

      create(:signature)

      deduplicate

      expect(Signature.where(user: user).ids).to eq [signature.id]
      expect(Signature.where(user_id: duplicate_user.id)).to be_empty
      expect(Signature.count).to eq 2
    end
  end

  describe "legislation" do
    it "reassigns annotations, including hidden ones" do
      annotation1 = create(:legislation_annotation, author: duplicate_user)
      annotation2 = create(:legislation_annotation, author: duplicate_user, hidden_at: Time.current)

      create(:legislation_annotation)

      deduplicate

      expect(Legislation::Annotation.with_hidden.where(author: user).ids).to match_array(
        [annotation1.id, annotation2.id]
      )
      expect(Legislation::Annotation.with_hidden.where(author_id: duplicate_user.id)).to be_empty
      expect(Legislation::Annotation.with_hidden.count).to eq 3
    end

    it "reassigns answers" do
      answer = create(:legislation_answer, user: duplicate_user)

      create(:legislation_answer)

      deduplicate

      expect(Legislation::Answer.where(user: user).ids).to eq [answer.id]
      expect(Legislation::Answer.where(user_id: duplicate_user.id)).to be_empty
      expect(Legislation::Answer.count).to eq 2
    end

    it "reassigns legislation proposals, including hidden ones" do
      proposal1 = create(:legislation_proposal, author: duplicate_user)
      proposal2 = create(:legislation_proposal, :hidden, author: duplicate_user)

      create(:legislation_proposal)

      deduplicate

      all_proposals = Legislation::Proposal.with_hidden

      expect(all_proposals.where(author: user).ids).to match_array [proposal1.id, proposal2.id]
      expect(all_proposals.where(author_id: duplicate_user.id)).to be_empty
      expect(all_proposals.count).to eq 3
    end

    it "reassigns legislation questions, including hidden ones" do
      question1 = create(:legislation_question, author: duplicate_user)
      question2 = create(:legislation_question, author: duplicate_user, hidden_at: Time.current)

      create(:legislation_question)

      deduplicate

      expect(Legislation::Question.with_hidden.where(author: user).ids).to match_array(
        [question1.id, question2.id]
      )
      expect(Legislation::Question.with_hidden.where(author_id: duplicate_user.id)).to be_empty
      expect(Legislation::Question.with_hidden.count).to eq 3
    end
  end

  describe "polls" do
    it "reassigns polls, including hidden ones" do
      poll1 = create(:poll, :with_author, author: duplicate_user)
      poll2 = create(:poll, :with_author, :hidden, author: duplicate_user)

      create(:poll)

      deduplicate

      expect(Poll.with_hidden.where(author: user).ids).to match_array [poll1.id, poll2.id]
      expect(Poll.with_hidden.where(author_id: duplicate_user.id)).to be_empty
      expect(Poll.with_hidden.count).to eq 3
    end

    it "reassigns poll questions, including hidden ones" do
      question1 = create(:poll_question, author: duplicate_user)
      question2 = create(:poll_question, author: duplicate_user, hidden_at: Time.current)

      create(:poll_question)

      deduplicate

      expect(Poll::Question.with_hidden.where(author: user).ids).to match_array [question1.id, question2.id]
      expect(Poll::Question.with_hidden.where(author_id: duplicate_user.id)).to be_empty
      expect(Poll::Question.with_hidden.count).to eq 3
    end

    it "reassigns poll answers" do
      answer1 = create(:poll_answer, author: duplicate_user)
      answer2 = create(:poll_answer, author: duplicate_user)

      create(:poll_answer)

      deduplicate

      expect(Poll::Answer.where(author: user).ids).to match_array [answer1.id, answer2.id]
      expect(Poll::Answer.where(author_id: duplicate_user.id)).to be_empty
      expect(Poll::Answer.count).to eq 3
    end

    it "deletes the duplicate's answer if the user has already answered the same option" do
      question = create(:poll_question, :abc)
      option = question.question_options.first
      answer = create(:poll_answer, question: question, option: option, author: user)
      create(:poll_answer, question: question, option: option, author: duplicate_user)
      other_answer = create(:poll_answer, question: question,
                                          option: question.question_options.last,
                                          author: duplicate_user)

      deduplicate

      expect(Poll::Answer.where(author: user).ids).to match_array [answer.id, other_answer.id]
      expect(Poll::Answer.where(author_id: duplicate_user.id)).to be_empty
      expect(Poll::Answer.count).to eq 2
    end

    it "reassigns partial results" do
      result1 = create(:poll_partial_result, author: duplicate_user)
      result2 = create(:poll_partial_result, author: duplicate_user)

      create(:poll_partial_result)

      deduplicate

      expect(Poll::PartialResult.where(author: user).ids).to match_array [result1.id, result2.id]
      expect(Poll::PartialResult.where(author_id: duplicate_user.id)).to be_empty
      expect(Poll::PartialResult.count).to eq 3
    end

    it "reassigns recounts" do
      recount1 = create(:poll_recount, author: duplicate_user)
      recount2 = create(:poll_recount, author: duplicate_user)

      create(:poll_recount)

      deduplicate

      expect(Poll::Recount.where(author: user).ids).to match_array [recount1.id, recount2.id]
      expect(Poll::Recount.where(author_id: duplicate_user.id)).to be_empty
      expect(Poll::Recount.count).to eq 3
    end
  end

  describe "comments" do
    it "reassigns comments, including hidden ones" do
      comment1 = create(:comment, user: duplicate_user)
      comment2 = create(:comment, :hidden, user: duplicate_user)

      create(:comment)

      deduplicate

      expect(Comment.with_hidden.where(user: user).ids).to match_array [comment1.id, comment2.id]
      expect(Comment.with_hidden.where(user_id: duplicate_user.id)).to be_empty
      expect(Comment.with_hidden.count).to eq 3
    end
  end

  describe "attachments" do
    it "reassigns documents" do
      document = create(:document, user: duplicate_user)

      create(:document)

      deduplicate

      expect(Document.where(user: user).ids).to eq [document.id]
      expect(Document.where(user_id: duplicate_user.id)).to be_empty
      expect(Document.count).to eq 2
    end

    it "reassigns images" do
      image = create(:image, user: duplicate_user)

      create(:image)

      deduplicate

      expect(Image.where(user: user).ids).to eq [image.id]
      expect(Image.where(user_id: duplicate_user.id)).to be_empty
      expect(Image.count).to eq 2
    end
  end

  describe "direct messages" do
    it "reassigns sent and received direct messages" do
      sent = create(:direct_message, sender: duplicate_user)
      received = create(:direct_message, receiver: duplicate_user)

      create(:direct_message)

      deduplicate

      expect(DirectMessage.where(sender: user).ids).to eq [sent.id]
      expect(DirectMessage.where(receiver: user).ids).to eq [received.id]
      expect(DirectMessage.where(sender_id: duplicate_user.id)).to be_empty
      expect(DirectMessage.where(receiver_id: duplicate_user.id)).to be_empty
      expect(DirectMessage.count).to eq 3
    end
  end

  describe "activities" do
    it "reassigns activities and activities on the duplicate user" do
      activity = create(:activity, user: duplicate_user)
      user_activity = create(:activity, actionable: duplicate_user)

      create(:activity)

      deduplicate

      expect(Activity.where(user: user).ids).to eq [activity.id]
      expect(Activity.where(actionable_type: "User", actionable_id: user.id).ids).to eq [user_activity.id]
      expect(Activity.where(user_id: duplicate_user.id)).to be_empty
      expect(Activity.where(actionable_id: duplicate_user.id)).to be_empty
      expect(Activity.count).to eq 3
    end
  end

  describe "audits" do
    it "reassigns audits by the duplicate user and audits on the duplicate user" do
      investment = create(:budget_investment)

      expect(Audit.count).to eq 1

      audit = Audit.create!(user: duplicate_user, user_type: "User", auditable: investment,
                            action: "update", audited_changes: { "title" => ["a", "b"] })
      user_audit = Audit.create!(user: create(:user), auditable: duplicate_user,
                                 action: "update", audited_changes: { "username" => ["a", "b"] })

      expect(Audit.count).to eq 3

      deduplicate

      expect(Audit.where(user_id: user.id).ids).to eq [audit.id]
      expect(Audit.where(auditable_type: "User", auditable_id: user.id).ids).to eq [user_audit.id]
      expect(Audit.where(user_id: duplicate_user.id)).to be_empty
      expect(Audit.where(auditable_id: duplicate_user.id)).to be_empty
      expect(Audit.count).to eq 3
    end

    it "does not reassign audits performed by another type of user" do
      administrator = create(:administrator, user: create(:user))
      investment = create(:budget_investment)

      expect(Audit.count).to eq 1

      audit = Audit.create!(user: administrator, auditable: investment,
                            action: "update", audited_changes: {})

      expect(Audit.count).to eq 2

      deduplicate

      expect(audit.reload.user_id).to eq administrator.id
      expect(Audit.count).to eq 2
    end
  end

  describe "follows" do
    it "reassigns follows on the duplicate user and follows by the duplicate user" do
      follow = create(:follow, followable: duplicate_user)
      user_follow = create(:follow, user: duplicate_user, followable: create(:debate))

      create(:follow, followable: create(:debate))

      deduplicate

      expect(Follow.where(followable_type: "User", followable_id: user.id).ids).to eq [follow.id]
      expect(Follow.where(user: user).ids).to eq [user_follow.id]
      expect(Follow.where(followable_id: duplicate_user.id)).to be_empty
      expect(Follow.where(user_id: duplicate_user.id)).to be_empty
      expect(Follow.count).to eq 3
    end
  end

  describe "topics" do
    it "reassigns topics, including hidden ones" do
      topic1 = create(:topic, author: duplicate_user)
      topic2 = create(:topic, author: duplicate_user, hidden_at: Time.current)

      create(:topic)

      deduplicate

      expect(Topic.with_hidden.where(author: user).ids).to match_array [topic1.id, topic2.id]
      expect(Topic.with_hidden.where(author_id: duplicate_user.id)).to be_empty
      expect(Topic.with_hidden.count).to eq 3
    end
  end

  describe "related contents" do
    it "reassigns related contents, including hidden ones" do
      related_content1 = create(:related_content, :proposals, author: duplicate_user)
      related_content2 = create(:related_content, :proposals, author: duplicate_user, hidden_at: Time.current)

      create(:related_content, :proposals)

      deduplicate

      expect(related_content1.reload.author_id).to eq user.id
      expect(related_content2.reload.author_id).to eq user.id
      expect(RelatedContent.with_hidden.where(author_id: duplicate_user.id)).to be_empty
      expect(RelatedContent.with_hidden.count).to eq 6
    end

    it "reassigns related content scores" do
      score = create(:related_content_score, user: duplicate_user)

      create(:related_content_score)

      deduplicate

      expect(RelatedContentScore.where(user: user).ids).to eq [score.id]
      expect(RelatedContentScore.where(user_id: duplicate_user.id)).to be_empty
    end

    it "deletes the duplicate's score if the user has already scored the same related content" do
      related_content = create(:related_content, :proposals)
      other_related_content = create(:related_content, :proposals)
      score = create(:related_content_score, related_content: related_content, user: user)
      create(:related_content_score, related_content: related_content, user: duplicate_user)
      other_score = create(:related_content_score, related_content: other_related_content,
                                                   user: duplicate_user)

      deduplicate

      expect(RelatedContentScore.where(user: user).ids).to match_array [score.id, other_score.id]
      expect(RelatedContentScore.where(user_id: duplicate_user.id)).to be_empty
      expect(related_content.reload.related_content_scores_count).to eq 2
      expect(other_related_content.reload.related_content_scores_count).to eq 2
    end
  end

  describe "flags" do
    it "reassigns flags" do
      flag = create(:flag, user: duplicate_user)

      create(:flag)

      deduplicate

      expect(Flag.where(user: user).ids).to eq [flag.id]
      expect(Flag.where(user_id: duplicate_user.id)).to be_empty
      expect(Flag.count).to eq 2
    end
  end

  describe "dashboard tasks" do
    it "reassigns administrator tasks" do
      task = create(:dashboard_administrator_task, user: duplicate_user)

      create(:dashboard_administrator_task)

      deduplicate

      expect(Dashboard::AdministratorTask.where(user: user).ids).to eq [task.id]
      expect(Dashboard::AdministratorTask.where(user_id: duplicate_user.id)).to be_empty
      expect(Dashboard::AdministratorTask.count).to eq 2
    end
  end

  describe "failed census calls" do
    it "reassigns failed census calls and resets the user's counter" do
      failed_census_call = create(:failed_census_call, user: duplicate_user)
      create(:failed_census_call, user: user)

      expect(user.reload.failed_census_calls_count).to eq 1

      deduplicate

      expect(FailedCensusCall.where(user: user).ids).to include(failed_census_call.id)
      expect(FailedCensusCall.where(user_id: duplicate_user.id)).to be_empty
      expect(user.reload.failed_census_calls_count).to eq 2
      expect(FailedCensusCall.count).to eq 2
    end
  end

  describe "notifications" do
    it "reassigns notifications and resets the user's counter" do
      notification = create(:notification, user: duplicate_user)
      create(:notification, user: user)

      expect(user.reload.notifications_count).to eq 1

      deduplicate

      expect(Notification.where(user: user).ids).to include(notification.id)
      expect(Notification.where(user_id: duplicate_user.id)).to be_empty
      expect(user.reload.notifications_count).to eq 2
      expect(Notification.count).to eq 2
    end
  end

  describe "visits" do
    it "reassigns visits" do
      visit = create(:visit, user: duplicate_user)

      create(:visit)

      deduplicate

      expect(Visit.where(user: user).ids).to eq [visit.id]
      expect(Visit.where(user_id: duplicate_user.id)).to be_empty
      expect(Visit.count).to eq 2
    end
  end

  describe "identities" do
    it "reassigns identities" do
      identity1 = create(:identity, user: duplicate_user, provider: "twitter", uid: "123")
      identity2 = create(:identity, user: duplicate_user, provider: "facebook", uid: "456")

      create(:identity)

      deduplicate

      expect(Identity.where(user: user).ids).to match_array [identity1.id, identity2.id]
      expect(Identity.where(user_id: duplicate_user.id)).to be_empty
      expect(Identity.count).to eq 3
    end

    it "deletes an identity that already exists on the user and reassigns the rest" do
      create(:identity, user: user, provider: "twitter", uid: "123")
      now = Time.current
      Identity.insert!({ user_id: duplicate_user.id,
                         provider: "twitter",
                         uid: "123",
                         created_at: now,
                         updated_at: now })
      duplicate_identity = Identity.where(user_id: duplicate_user.id, provider: "twitter", uid: "123").first
      unique_identity = create(:identity, user: duplicate_user, provider: "facebook", uid: "456")

      deduplicate

      expect(Identity.where(user: user, provider: "twitter", uid: "123").count).to eq 1
      expect(Identity.exists?(duplicate_identity.id)).to be false
      expect(Identity.where(user: user, provider: "facebook", uid: "456").ids).to eq [unique_identity.id]
    end
  end

  describe "organizations" do
    it "reassigns the organization if the user does not have one" do
      organization = create(:organization, user: duplicate_user)
      create(:organization)

      deduplicate

      expect(Organization.where(user: user).ids).to eq [organization.id]
      expect(Organization.where(user_id: duplicate_user.id)).to be_empty
      expect(Organization.count).to eq 2
    end

    it "deletes the duplicate's organization if the user already has one" do
      create(:organization, user: user)
      duplicate_organization = create(:organization, user: duplicate_user)

      deduplicate

      expect(Organization.where(user: user).count).to eq 1
      expect(Organization.where(user_id: duplicate_user.id)).to be_empty
      expect(Organization.exists?(duplicate_organization.id)).to be false
      expect(Organization.count).to eq 1
    end
  end

  describe "locks" do
    it "reassigns the lock if the user does not have one" do
      lock = create(:lock, user: duplicate_user)
      create(:lock)

      deduplicate

      expect(Lock.where(user: user).ids).to eq [lock.id]
      expect(Lock.where(user_id: duplicate_user.id)).to be_empty
      expect(Lock.count).to eq 2
    end

    it "deletes the duplicate's lock if the user already has one" do
      create(:lock, user: user)
      duplicate_lock = create(:lock, user: duplicate_user)

      deduplicate

      expect(Lock.where(user: user).count).to eq 1
      expect(Lock.where(user_id: duplicate_user.id)).to be_empty
      expect(Lock.exists?(duplicate_lock.id)).to be false
      expect(Lock.count).to eq 1
    end
  end

  describe "roles" do
    [:administrator, :valuator, :moderator, :manager,
     :sdg_manager, :poll_officer].each do |role_name|
      it "reassigns the #{role_name} role when only the duplicate has it" do
        role = create(role_name, user: duplicate_user)

        deduplicate

        expect(role.class.where(user_id: user.id).ids).to eq [role.id]
        expect(role.class.where(user_id: duplicate_user.id)).to be_empty
        expect(user.reload.public_send("#{role_name}?")).to be true
        expect(role.class.count).to eq 1
      end
    end

    describe "when both users are administrators" do
      it "keeps the user's administrator, merges the associated records and deletes the duplicate's" do
        administrator = create(:administrator, user: user)
        duplicate_administrator = create(:administrator, user: duplicate_user)

        shared_budget = create(:budget)
        BudgetAdministrator.create!(budget: shared_budget, administrator: administrator)
        BudgetAdministrator.create!(budget: shared_budget, administrator: duplicate_administrator)
        own_budget = create(:budget)
        BudgetAdministrator.create!(budget: own_budget, administrator: duplicate_administrator)

        investment = create(:budget_investment, administrator: duplicate_administrator)
        comment = create(:comment, commentable: investment, user: user,
                                   administrator_id: duplicate_administrator.id)

        deduplicate

        expect(Administrator.where(user_id: user.id).ids).to eq [administrator.id]
        expect(Administrator.where(user_id: duplicate_user.id)).to be_empty
        expect(Administrator.count).to eq 1
        expect(BudgetAdministrator.where(budget: shared_budget).pluck(:administrator_id))
          .to eq [administrator.id]
        expect(BudgetAdministrator.where(budget: own_budget).pluck(:administrator_id))
          .to eq [administrator.id]
        expect(BudgetAdministrator.count).to eq 2
        expect(investment.reload.administrator_id).to eq administrator.id
        expect(comment.reload.administrator_id).to eq administrator.id
      end
    end

    describe "when both users are valuators" do
      it "keeps the user's valuator, merges the associated records and deletes the duplicate's" do
        valuator = create(:valuator, user: user)
        duplicate_valuator = create(:valuator, user: duplicate_user)

        shared_budget = create(:budget)
        BudgetValuator.create!(budget: shared_budget, valuator: valuator)
        BudgetValuator.create!(budget: shared_budget, valuator: duplicate_valuator)
        own_budget = create(:budget)
        BudgetValuator.create!(budget: own_budget, valuator: duplicate_valuator)

        shared_investment = create(:budget_investment)
        Budget::ValuatorAssignment.create!(investment: shared_investment, valuator: valuator)
        Budget::ValuatorAssignment.create!(investment: shared_investment, valuator: duplicate_valuator)
        own_investment = create(:budget_investment)
        Budget::ValuatorAssignment.create!(investment: own_investment, valuator: duplicate_valuator)

        deduplicate

        expect(Valuator.where(user_id: user.id).ids).to eq [valuator.id]
        expect(Valuator.where(user_id: duplicate_user.id)).to be_empty
        expect(Valuator.count).to eq 1
        expect(BudgetValuator.where(budget: shared_budget).pluck(:valuator_id)).to eq [valuator.id]
        expect(BudgetValuator.where(budget: own_budget).pluck(:valuator_id)).to eq [valuator.id]
        expect(BudgetValuator.count).to eq 2
        expect(Budget::ValuatorAssignment.where(investment: shared_investment).pluck(:valuator_id))
          .to eq [valuator.id]
        expect(Budget::ValuatorAssignment.where(investment: own_investment).pluck(:valuator_id))
          .to eq [valuator.id]
        expect(Budget::ValuatorAssignment.count).to eq 2
        expect(valuator.reload.budget_investments_count).to eq 2
        expect(shared_investment.reload.valuator_assignments_count).to eq 1
        expect(own_investment.reload.valuator_assignments_count).to eq 1
      end
    end

    describe "when both users are moderators" do
      it "keeps the user's moderator, assigns its comments and deletes the duplicate's" do
        moderator = create(:moderator, user: user)
        duplicate_moderator = create(:moderator, user: duplicate_user)

        comment = create(:comment, commentable: create(:debate), user: user,
                                   moderator_id: duplicate_moderator.id)

        deduplicate

        expect(Moderator.where(user_id: user.id).ids).to eq [moderator.id]
        expect(Moderator.where(user_id: duplicate_user.id)).to be_empty
        expect(Moderator.count).to eq 1
        expect(comment.reload.moderator_id).to eq moderator.id
      end
    end

    describe "when both users are managers" do
      it "keeps the user's manager and deletes the duplicate's" do
        manager = create(:manager, user: user)
        create(:manager, user: duplicate_user)

        deduplicate

        expect(Manager.where(user_id: user.id).ids).to eq [manager.id]
        expect(Manager.where(user_id: duplicate_user.id)).to be_empty
        expect(Manager.count).to eq 1
      end
    end

    describe "when both users are SDG managers" do
      it "keeps the user's SDG manager and deletes the duplicate's" do
        sdg_manager = create(:sdg_manager, user: user)
        create(:sdg_manager, user: duplicate_user)

        deduplicate

        expect(SDG::Manager.where(user_id: user.id).ids).to eq [sdg_manager.id]
        expect(SDG::Manager.where(user_id: duplicate_user.id)).to be_empty
        expect(SDG::Manager.count).to eq 1
      end
    end

    describe "when both users are poll officers" do
      it "keeps the user's officer, merges the associated records and deletes the duplicate's" do
        officer = create(:poll_officer, user: user)
        duplicate_officer = create(:poll_officer, user: duplicate_user)

        create(:poll_officer_assignment, officer: duplicate_officer)
        create(:poll_voter, officer: duplicate_officer)
        create(:failed_census_call, poll_officer: duplicate_officer)

        booth = create(:poll_booth)
        create(:poll_shift, officer: officer, booth: booth, date: Date.current)
        create(:poll_shift, officer: duplicate_officer, booth: booth, date: Date.current)
        create(:poll_shift, officer: duplicate_officer, booth: booth, date: Date.current + 1)

        deduplicate

        expect(Poll::Officer.where(user_id: user.id).ids).to eq [officer.id]
        expect(Poll::Officer.where(user_id: duplicate_user.id)).to be_empty
        expect(Poll::Officer.count).to eq 1
        expect(Poll::OfficerAssignment.pluck(:officer_id)).to eq [officer.id]
        expect(Poll::OfficerAssignment.count).to eq 1
        expect(Poll::Voter.pluck(:officer_id)).to eq [officer.id]
        expect(FailedCensusCall.where(poll_officer_id: officer.id).count).to eq 1
        expect(FailedCensusCall.count).to eq 1
        expect(officer.reload.failed_census_calls_count).to eq 1
        expect(Poll::Shift.where(booth: booth, date: Date.current).count).to eq 1
        expect(Poll::Shift.where(booth: booth, date: Date.current).pluck(:officer_id)).to eq [officer.id]
        expect(Poll::Shift.where(booth: booth, date: Date.current + 1).pluck(:officer_id)).to eq [officer.id]
        expect(Poll::Shift.count).to eq 2
      end
    end
  end

  describe "when the duplicate user is hidden" do
    it "moves its data and keeps it hidden" do
      duplicate_user.update_column(:hidden_at, Time.current)
      debate = create(:debate, author: duplicate_user)
      comment = create(:comment, user: duplicate_user, commentable: debate)

      deduplicate

      expect(User.exists?(duplicate_user.id)).to be false
      expect(User.with_hidden.exists?(duplicate_user.id)).to be true
      expect(User.with_hidden.count).to eq 2
      expect(debate.reload.author_id).to eq user.id
      expect(comment.reload.user_id).to eq user.id
    end
  end

  def deduplicate
    UserDeduplicator.new(user, duplicate_user).deduplicate
  end
end
