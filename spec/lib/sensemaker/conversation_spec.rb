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
      expect(context_result).to include("Questions and Responses:")
      expect(context_result).to include("Q: #{poll.questions.first.title}:")
      expect(context_result).to include(" - #{answer_one.option.title}")
      expect(context_result).to include(" - #{answer_two.option.title}")
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
        "This question is part of the legislation process, \"#{question.process.title}\""
      )
      expect(context_result).not_to include("Question Responses:")
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
      expect(context_result).to include("Question Responses:")
      expect(context_result).to include(" - #{question.question_options.first.value}")
      expect(context_result).to include(" - #{question.question_options.last.value}")
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
        expect(context_result).to include("Comments: #{conversation.comments.size}")
      end
    end
  end
end

