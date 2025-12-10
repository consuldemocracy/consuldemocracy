require "rails_helper"

describe Sensemaker::Conversation do
  let(:user) { create(:user) }

  describe "#compile_context" do
    it "can compile context for Poll" do
      answer_one = create(:poll_answer)
      answer_two = create(:poll_answer)
      poll = answer_one.poll

      expect(answer_one.persisted?).to be true
      expect(answer_two.persisted?).to be true
      expect(poll.persisted?).to be true

      conversation = Sensemaker::Conversation.new("Poll", poll.id)
      context_result = conversation.compile_context

      expect(context_result).to be_present
      expect(context_result).to include("### Questions and Responses")
      expect(context_result).to include("#### Q: #{poll.questions.first.title}")
      expect(context_result).to include("- #{answer_one.option.title}")
      expect(context_result).to include("- #{answer_two.option.title}")
    end

    it "can compile context for Proposal" do
      proposal = create(:proposal)
      expect(proposal.persisted?).to be true

      conversation = Sensemaker::Conversation.new("Proposal", proposal.id)
      context_result = conversation.compile_context
      expect(context_result).to be_present
      expect(context_result).to include(
        "This proposal has #{proposal.total_votes} votes out of #{Proposal.votes_needed_for_success} required"
      )
    end

    it "can compile context for Debate" do
      debate = create(:debate)
      expect(debate.persisted?).to be true

      conversation = Sensemaker::Conversation.new("Debate", debate.id)
      context_result = conversation.compile_context
      expect(context_result).to be_present
      expect(context_result).to include(
        "This debate has #{debate.cached_votes_up} votes for and #{debate.cached_votes_down} votes against"
      )
    end

    it "can compile context for Legislation::Proposal" do
      proposal = create(:legislation_proposal)
      expect(proposal.persisted?).to be true

      conversation = Sensemaker::Conversation.new("Legislation::Proposal", proposal.id)
      context_result = conversation.compile_context
      expect(context_result).to be_present
      expect(context_result).to include(
        "This proposal is part of the legislation process, \"#{proposal.process.title}\""
      )
    end

    it "can compile context for Legislation::Question without question options" do
      question = create(:legislation_question)
      expect(question.persisted?).to be true

      conversation = Sensemaker::Conversation.new("Legislation::Question", question.id)
      context_result = conversation.compile_context
      expect(context_result).to be_present
      expect(context_result).to include(
        "This debate is part of the legislation process, \"#{question.process.title}\""
      )
      expect(context_result).not_to include("### Debate Responses")
    end

    it "can compile context for Legislation::Question with question options" do
      question = create(:legislation_question)
      2.times do
        create(:legislation_question_option, question: question)
      end
      3.times do
        create(:legislation_answer, question: question, question_option: question.question_options.sample)
      end
      expect(question.persisted?).to be true

      conversation = Sensemaker::Conversation.new("Legislation::Question", question.id)
      context_result = conversation.compile_context
      expect(context_result).to be_present
      expect(context_result).to include("### Debate Responses")
      expect(context_result).to include("- #{question.question_options.first.value}")
      expect(context_result).to include("- #{question.question_options.last.value}")
    end

    it "can compile context for Budget with investments" do
      budget = create(:budget)
      expect(budget.persisted?).to be true

      3.times do
        create(:budget_investment, budget: budget)
      end

      conversation = Sensemaker::Conversation.new("Budget", budget.id)
      context_result = conversation.compile_context

      expect(context_result).to be_present
      expect(context_result).to include("- Comments: #{conversation.comments.size}")
      expect(conversation.comments.size).to eq(3)
    end

    it "can compile context for Budget::Group with investments" do
      budget = create(:budget)
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)
      expect(group.persisted?).to be true

      3.times do
        create(:budget_investment, heading: heading)
      end

      conversation = Sensemaker::Conversation.new("Budget::Group", group.id)
      context_result = conversation.compile_context

      expect(context_result).to be_present
      expect(context_result).to include("- Comments: #{conversation.comments.size}")
      expect(conversation.comments.size).to eq(3)
    end

    it "can compile context for other target types" do
      target_types = Sensemaker::Job::ANALYSABLE_TYPES - ["Poll", "Legislation::Question",
                                                          "Legislation::Proposal", "Debate",
                                                          "Legislation::QuestionOption",
                                                          "Budget", "Budget::Group"]
      target_types.each do |target_type|
        target_factory = target_type.downcase.gsub("::", "_").to_sym
        target = create(target_factory)
        expect(target.persisted?).to be true
        3.times do
          create(:comment, commentable: target, user: user)
        end
        conversation = Sensemaker::Conversation.new(target_type, target.id)
        context_result = conversation.compile_context
        expect(context_result).to be_present, "Failed to compile context for #{target_factory}"
        expect(context_result).to include("- Comments: #{conversation.comments.size}")
      end
    end
  end

  describe "#comments" do
    describe "avoids filtering out in job run by vote padding" do
      it "pads Budget investment votes by 1 when votes are 0" do
        budget = create(:budget)
        _investment = create(:budget_investment, budget: budget, cached_votes_up: 0)

        conversation = Sensemaker::Conversation.new("Budget", budget.id)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.cached_votes_up).to eq(1)
        expect(comments.first.cached_votes_total).to eq(1)
      end

      it "pads Budget investment votes by 1 when votes exist" do
        budget = create(:budget)
        _investment = create(:budget_investment, budget: budget, cached_votes_up: 5)

        conversation = Sensemaker::Conversation.new("Budget", budget.id)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.cached_votes_up).to eq(6)
        expect(comments.first.cached_votes_total).to eq(6)
      end

      it "pads Budget::Group investment votes by 1 when votes are 0" do
        budget = create(:budget)
        group = create(:budget_group, budget: budget)
        heading = create(:budget_heading, group: group)
        _investment = create(:budget_investment, heading: heading, cached_votes_up: 0)

        conversation = Sensemaker::Conversation.new("Budget::Group", group.id)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.cached_votes_up).to eq(1)
        expect(comments.first.cached_votes_total).to eq(1)
      end

      it "pads Budget::Group investment votes by 1 when votes exist" do
        budget = create(:budget)
        group = create(:budget_group, budget: budget)
        heading = create(:budget_heading, group: group)
        _investment = create(:budget_investment, heading: heading, cached_votes_up: 3)

        conversation = Sensemaker::Conversation.new("Budget::Group", group.id)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.cached_votes_up).to eq(4)
        expect(comments.first.cached_votes_total).to eq(4)
      end

      it "pads Proposal votes by 1 when votes are 0" do
        _proposal = create(:proposal, cached_votes_up: 0)

        conversation = Sensemaker::Conversation.new("Proposal", nil)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.cached_votes_up).to eq(1)
        expect(comments.first.cached_votes_total).to eq(1)
      end

      it "pads Proposal votes by 1 when votes exist" do
        _proposal = create(:proposal, cached_votes_up: 10)

        conversation = Sensemaker::Conversation.new("Proposal", nil)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.cached_votes_up).to eq(11)
        expect(comments.first.cached_votes_total).to eq(11)
      end
    end
  end
end
