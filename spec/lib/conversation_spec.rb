require "rails_helper"

HTML_TAGS = %w[<p> <strong> <em> </p>].freeze

describe Conversation do
  let(:user) { create(:user) }

  def expect_no_html_tags(content, tags = HTML_TAGS)
    tags.each { |tag| expect(content).not_to include(tag) }
  end

  shared_examples "rejects non-open-ended Poll::Question" do |method_name|
    it "raises ArgumentError" do
      conversation = Conversation.new("Poll::Question", question.id)
      expect { conversation.send(method_name) }.to raise_error(ArgumentError, /only supported for open-ended Poll::Question/)
    end
  end

  describe "#compile_context" do
    it "can compile context for Poll" do
      poll = create(:poll)

      3.times do
        create(:comment, commentable: poll, user: user)
      end

      conversation = Conversation.new("Poll", poll.id)
      context_result = conversation.compile_context

      expect(context_result).to be_present
      expect(context_result).to include("- Comments: #{conversation.comments.size}")
      expect(conversation.comments.size).to eq(3)
    end

    it "can compile context for Proposal" do
      proposal = create(:proposal)

      conversation = Conversation.new("Proposal", proposal.id)
      context_result = conversation.compile_context
      expect(context_result).to be_present
      expect(context_result).to include(
        "This proposal has #{proposal.total_votes} votes out of #{Proposal.votes_needed_for_success} required"
      )
    end

    it "sanitizes HTML from Proposal description and summary" do
      proposal = create(:proposal,
                        description: "<p>This is a <strong>description</strong> with <em>HTML</em> tags.</p>",
                        summary: "<p>This is a <strong>summary</strong>.</p>")
      conversation = Conversation.new("Proposal", proposal.id)
      context_result = conversation.compile_context

      expect(context_result).to include("This is a description with HTML tags.")
      expect(context_result).to include("This is a summary.")
      expect_no_html_tags(context_result)
    end

    it "decodes HTML entities like &nbsp; and &#39; from Proposal description" do
      proposal = create(:proposal,
                        description: "<p>Tell us what matters to you and share your&nbsp;ideas. " \
                                     "You&#39;ve seen this before.</p>")
      conversation = Conversation.new("Proposal", proposal.id)
      context_result = conversation.compile_context

      expected_text = "Tell us what matters to you and share your ideas. You've seen this before."
      expect(context_result).to include(expected_text)
      expect(context_result).not_to include("&nbsp;")
      expect(context_result).not_to include("&#39;")
    end

    it "can compile context for Debate" do
      debate = create(:debate)

      conversation = Conversation.new("Debate", debate.id)
      context_result = conversation.compile_context
      expect(context_result).to be_present
      expect(context_result).to include(
        "This debate has #{debate.cached_votes_up} votes for and #{debate.cached_votes_down} votes against"
      )
    end

    it "sanitizes HTML from Debate description" do
      debate = create(:debate, description: "<p><strong>How do you feel</strong> about <em>safety</em>?</p>")
      conversation = Conversation.new("Debate", debate.id)
      context_result = conversation.compile_context

      expect(context_result).to include("How do you feel about safety?")
      expect_no_html_tags(context_result)
    end

    it "decodes HTML entities like &nbsp; from Debate description" do
      debate = create(:debate,
                      description: "<p>How do you feel about the overall safety of our community&nbsp; " \
                                   "and what are your biggest concerns?</p>")
      conversation = Conversation.new("Debate", debate.id)
      context_result = conversation.compile_context

      expected_text = "How do you feel about the overall safety of our community and " \
                      "what are your biggest concerns?"
      expect(context_result).to include(expected_text)
      expect(context_result).not_to include("&nbsp;")
      expect(context_result).not_to include("<p>")
    end

    it "can compile context for Legislation::Proposal" do
      proposal = create(:legislation_proposal)

      conversation = Conversation.new("Legislation::Proposal", proposal.id)
      context_result = conversation.compile_context
      expect(context_result).to be_present
      expect(context_result).to include(
        "This proposal is part of the legislation process, \"#{proposal.process.title}\""
      )
    end

    it "sanitizes HTML from Legislation::Proposal description and summary" do
      proposal = create(:legislation_proposal,
                        description: "<p>Legislation <strong>description</strong> with HTML.</p>",
                        summary: "<p>Legislation <em>summary</em>.</p>")
      conversation = Conversation.new("Legislation::Proposal", proposal.id)
      context_result = conversation.compile_context

      expect(context_result).to include("Legislation description with HTML.")
      expect(context_result).to include("Legislation summary.")
      expect_no_html_tags(context_result, %w[<p> <strong> <em>])
    end

    it "can compile context for Legislation::Question without question options" do
      question = create(:legislation_question)

      conversation = Conversation.new("Legislation::Question", question.id)
      context_result = conversation.compile_context
      expect(context_result).to be_present
      expect(context_result).to include(
        "This debate is part of the legislation process, \"#{question.process.title}\""
      )
      expect(context_result).not_to include("### Debate Responses")
    end

    it "sanitizes HTML from Legislation::Question description" do
      question = create(:legislation_question,
                        description: "<p>Question <strong>description</strong> with <em>HTML</em>.</p>")
      conversation = Conversation.new("Legislation::Question", question.id)
      context_result = conversation.compile_context

      expect(context_result).to include("Question description with HTML.")
      expect_no_html_tags(context_result, %w[<p> <strong> <em>])
    end

    it "can compile context for Legislation::Question with question options" do
      question = create(:legislation_question)
      2.times do
        create(:legislation_question_option, question: question)
      end
      3.times do
        create(:legislation_answer, question: question, question_option: question.question_options.sample)
      end

      conversation = Conversation.new("Legislation::Question", question.id)
      context_result = conversation.compile_context
      expect(context_result).to be_present
      expect(context_result).to include("### Debate Responses")
      expect(context_result).to include("- #{question.question_options.first.value}")
      expect(context_result).to include("- #{question.question_options.last.value}")
    end

    it "can compile context for Budget with investments" do
      budget = create(:budget)

      3.times do
        create(:budget_investment, budget: budget)
      end

      conversation = Conversation.new("Budget", budget.id)
      context_result = conversation.compile_context

      expect(context_result).to be_present
      expect(context_result).to include("- Comments: #{conversation.comments.size}")
      expect(conversation.comments.size).to eq(3)
    end

    it "can compile context for Budget::Group with investments" do
      budget = create(:budget)
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)

      3.times do
        create(:budget_investment, heading: heading)
      end

      conversation = Conversation.new("Budget::Group", group.id)
      context_result = conversation.compile_context

      expect(context_result).to be_present
      expect(context_result).to include("- Comments: #{conversation.comments.size}")
      expect(conversation.comments.size).to eq(3)
    end

    it_behaves_like "rejects non-open-ended Poll::Question", :compile_context do
      let(:poll) { create(:poll) }
      let(:question) do
        q = create(:poll_question_unique, poll: poll, title: "Test Question")
        create(:poll_question_option, question: q, title: "Option 1")
        create(:poll_question_option, question: q, title: "Option 2")
        q
      end
    end

    it "can compile context for Poll::Question with open-ended question" do
      poll = create(:poll)
      question = create(:poll_question_open, poll: poll, title: "Open Question")
      create(:poll_answer, question: question, answer: "First answer", option: nil)
      create(:poll_answer, question: question, answer: "Second answer", option: nil)

      conversation = Conversation.new("Poll::Question", question.id)
      context_result = conversation.compile_context

      expect(context_result).to be_present
      expect(context_result).to include(
        "This Poll is composed of 1 question(s). The questions are as follows:"
      )
      expect(context_result).to include("Q1 (Open ended): Open Question")
    end

    it "can compile context for other target types" do
      target_types = Sensemaker::Job::ANALYSABLE_TYPES - ["Poll", "Poll::Question", "Legislation::Question",
                                                          "Legislation::Proposal", "Debate",
                                                          "Legislation::QuestionOption",
                                                          "Budget", "Budget::Group"]
      target_types.each do |target_type|
        target_factory = target_type.downcase.gsub("::", "_").to_sym
        target = create(target_factory)
        3.times do
          create(:comment, commentable: target, user: user)
        end
        conversation = Conversation.new(target_type, target.id)
        context_result = conversation.compile_context
        expect(context_result).to be_present, "Failed to compile context for #{target_factory}"
        expect(context_result).to include("- Comments: #{conversation.comments.size}")
      end
    end
  end

  describe "#comments" do
    describe "avoids filtering out in job run by vote padding" do
      shared_examples "pads votes by 1" do |expected_votes|
        it "pads so cached_votes_up and cached_votes_total are #{expected_votes}" do
          comments = conversation.comments
          expect(comments.size).to eq(1)
          expect(comments.first.cached_votes_up).to eq(expected_votes)
          expect(comments.first.cached_votes_total).to eq(expected_votes)
        end
      end

      context "Budget" do
        let(:budget) { create(:budget) }
        let(:conversation) { Conversation.new("Budget", budget.id) }

        it_behaves_like "pads votes by 1", 1 do
          before { create(:budget_investment, budget: budget, cached_votes_up: 0) }
        end

        it_behaves_like "pads votes by 1", 6 do
          before { create(:budget_investment, budget: budget, cached_votes_up: 5) }
        end
      end

      context "Budget::Group" do
        let(:budget) { create(:budget) }
        let(:group) { create(:budget_group, budget: budget) }
        let(:heading) { create(:budget_heading, group: group) }
        let(:conversation) { Conversation.new("Budget::Group", group.id) }

        it_behaves_like "pads votes by 1", 1 do
          before { create(:budget_investment, heading: heading, cached_votes_up: 0) }
        end

        it_behaves_like "pads votes by 1", 4 do
          before { create(:budget_investment, heading: heading, cached_votes_up: 3) }
        end
      end

      context "Proposal" do
        let(:conversation) { Conversation.new("Proposal", nil) }

        it_behaves_like "pads votes by 1", 1 do
          before { create(:proposal, cached_votes_up: 0) }
        end

        it_behaves_like "pads votes by 1", 11 do
          before { create(:proposal, cached_votes_up: 10) }
        end
      end
    end

    describe "sanitizes HTML from comment-like items" do
      it "sanitizes HTML from Budget::Investment description in comments" do
        budget = create(:budget)
        create(:budget_investment,
               budget: budget,
               title: "Test Investment",
               description: "<p>Investment <strong>description</strong> with <em>HTML</em> tags.</p>")

        conversation = Conversation.new("Budget", budget.id)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.body).to include("Test Investment")
        expect(comments.first.body).to include("Investment description with HTML tags.")
        expect_no_html_tags(comments.first.body)
      end

      it "sanitizes HTML from Proposal description in comments" do
        create(:proposal,
               title: "Test Proposal",
               description: "<p>Proposal <strong>description</strong> with <em>HTML</em> tags.</p>")

        conversation = Conversation.new("Proposal", nil)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.body).to include("Test Proposal")
        expect(comments.first.body).to include("Proposal description with HTML tags.")
        expect_no_html_tags(comments.first.body)
      end

      it "sanitizes HTML from Budget::Group investment description" do
        budget = create(:budget)
        group = create(:budget_group, budget: budget)
        heading = create(:budget_heading, group: group)
        create(:budget_investment,
               heading: heading,
               title: "Group Investment",
               description: "<p>Group <strong>investment</strong> description.</p>")

        conversation = Conversation.new("Budget::Group", group.id)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.body).to include("Group Investment")
        expect(comments.first.body).to include("Group investment description.")
        expect_no_html_tags(comments.first.body, %w[<p> <strong>])
      end
    end

    describe "handles Poll with standard comments" do
      it "collects standard comments on the poll when poll has only multi-choice questions" do
        poll = create(:poll)
        question = create(:poll_question_unique, poll: poll)
        create(:poll_question_option, question: question)
        comment1 = create(:comment, commentable: poll, user: user)
        comment2 = create(:comment, commentable: poll, user: user)

        conversation = Conversation.new("Poll", poll.id)
        comments = conversation.comments

        expect(comments.size).to eq(2)
        expect(comments.map(&:id)).to contain_exactly(comment1.id, comment2.id)
        expect(comments.map(&:body)).to contain_exactly(comment1.body, comment2.body)
      end

      it "excludes hidden comments" do
        poll = create(:poll)
        question = create(:poll_question_unique, poll: poll)
        create(:poll_question_option, question: question)
        visible_comment = create(:comment, commentable: poll, user: user)
        create(:comment, commentable: poll, user: user, hidden_at: Time.current)

        conversation = Conversation.new("Poll", poll.id)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.id).to eq(visible_comment.id)
      end
    end

    describe "handles Poll with open-ended questions (combined answers)" do
      it "combines all answers from a user across all questions" do
        poll = create(:poll)
        user1 = create(:user)
        user2 = create(:user)

        question1 = create(:poll_question_unique, poll: poll, title: "What is your favourite cake?")
        option1a = create(:poll_question_option, question: question1, title: "Chocolate")
        option1b = create(:poll_question_option, question: question1, title: "Vanilla")
        create(:poll_answer, question: question1, option: option1a, author: user1)
        create(:poll_answer, question: question1, option: option1b, author: user2)

        question2 = create(:poll_question_open, poll: poll, title: "What occasion should we have cake?")
        create(:poll_answer, question: question2, answer: "Christmas and birthdays", option: nil,
                             author: user1)
        create(:poll_answer, question: question2, answer: "Every day", option: nil, author: user2)

        conversation = Conversation.new("Poll", poll.id)
        comments = conversation.comments

        expect(comments.size).to eq(2)
        user1_comment = comments.find { |c| c.user_id == user1.id }
        user2_comment = comments.find { |c| c.user_id == user2.id }

        expect(user1_comment.body).to eq("Q1: Chocolate | Q2: Christmas and birthdays")
        expect(user2_comment.body).to eq("Q1: Vanilla | Q2: Every day")
        expect(user1_comment.cached_votes_up).to eq(1)
        expect(user1_comment.cached_votes_total).to eq(1)
      end

      it "handles multiple choice questions with multiple selections" do
        poll = create(:poll)
        user1 = create(:user)

        question1 = create(:poll_question_multiple, poll: poll, title: "What times should we have cake?")
        option1a = create(:poll_question_option, question: question1, title: "Morning")
        option1b = create(:poll_question_option, question: question1, title: "Afternoon")
        create(:poll_question_option, question: question1, title: "Evening")
        create(:poll_answer, question: question1, option: option1a, author: user1)
        create(:poll_answer, question: question1, option: option1b, author: user1)

        question2 = create(:poll_question_open, poll: poll, title: "What other feedback?")
        create(:poll_answer, question: question2, answer: "More cake please", option: nil, author: user1)

        conversation = Conversation.new("Poll", poll.id)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.body).to eq("Q1: Morning, Afternoon | Q2: More cake please")
      end

      it "handles users who haven't answered all questions" do
        poll = create(:poll)
        user1 = create(:user)
        user2 = create(:user)

        question1 = create(:poll_question_unique, poll: poll, title: "Question 1")
        option1 = create(:poll_question_option, question: question1, title: "Option A")
        create(:poll_answer, question: question1, option: option1, author: user1)
        create(:poll_answer, question: question1, option: option1, author: user2)

        question2 = create(:poll_question_open, poll: poll, title: "Question 2")
        create(:poll_answer, question: question2, answer: "Answer from user1", option: nil, author: user1)

        conversation = Conversation.new("Poll", poll.id)
        comments = conversation.comments

        expect(comments.size).to eq(2)
        user1_comment = comments.find { |c| c.user_id == user1.id }
        user2_comment = comments.find { |c| c.user_id == user2.id }

        expect(user1_comment.body).to eq("Q1: Option A | Q2: Answer from user1")
        expect(user2_comment.body).to eq("Q1: Option A")
      end

      it "only includes users who have at least one answer" do
        poll = create(:poll)
        user_with_answer = create(:user)
        create(:user)

        question1 = create(:poll_question_open, poll: poll, title: "Question 1")
        create(:poll_answer, question: question1, answer: "Some answer", option: nil,
                             author: user_with_answer)

        conversation = Conversation.new("Poll", poll.id)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.user_id).to eq(user_with_answer.id)
      end
    end

    describe "handles Poll::Question directly" do
      it_behaves_like "rejects non-open-ended Poll::Question", :comments do
        let(:poll) { create(:poll) }
        let(:question) do
          q = create(:poll_question_unique, poll: poll, title: "Single Question")
          create(:poll_question_option, question: q, title: "Yes")
          q
        end
      end

      it_behaves_like "rejects non-open-ended Poll::Question", :comments do
        let(:poll) { create(:poll) }
        let(:question) do
          q = create(:poll_question_multiple, poll: poll, title: "Multiple Question")
          create(:poll_question_option, question: q, title: "Option A")
          q
        end
      end

      it "handles single open-ended question" do
        poll = create(:poll)
        question = create(:poll_question_open, poll: poll, title: "Open Question")
        answer = create(:poll_answer, question: question, answer: "My answer", option: nil)

        conversation = Conversation.new("Poll::Question", question.id)
        comments = conversation.comments

        expect(comments.size).to eq(1)
        expect(comments.first.id).to eq("a_#{answer.id}")
        expect(comments.first.body).to eq("My answer")
      end
    end
  end
end
