module Sensemaker
  CommentLikeItem = Data.define(:id, :body, :cached_votes_up, :cached_votes_down, :cached_votes_total,
                                :user_id)

  class Conversation
    attr_reader :target

    def initialize(analysable_type, analysable_id = nil)
      @analysable_type = analysable_type
      @analysable_id = analysable_id

      if @analysable_id.present?
        @target = analysable_type.constantize.find(analysable_id)
      else
        @target = analysable_type.constantize
      end
    end

    def comments
      if @target.is_a?(Legislation::QuestionOption)
        # Case 2: Filter comments by users who selected this option
        user_ids = @target.answers.pluck(:user_id)
        if user_ids.any?
          @target.question.comments.includes(:user).where(hidden_at: nil, user_id: user_ids)
        else
          Comment.none
        end
      elsif @target.is_a?(Budget) || @target.is_a?(Budget::Group)
        # Case 3: Return investments wrapped as comment-like items
        investments = @target.investments.includes(:author).where(hidden_at: nil)
        investments.map do |investment|
          CommentLikeItem.new(
            id: investment.id,
            body: "#{investment.title}\n\n#{investment.description}",
            cached_votes_up: 0,
            cached_votes_down: 0,
            cached_votes_total: 0,
            user_id: investment.author_id
          )
        end
      elsif @analysable_type == "Proposal" && @analysable_id.nil?
        # Case 4: All proposals (class without ID)
        proposals = Proposal.includes(:author).where(hidden_at: nil)
        proposals.map do |proposal|
          CommentLikeItem.new(
            id: proposal.id,
            body: "#{proposal.title}\n\n#{proposal.description}",
            cached_votes_up: proposal.cached_votes_up || 0,
            cached_votes_down: 0,
            cached_votes_total: proposal.total_votes || 0,
            user_id: proposal.author_id
          )
        end
      else
        # Case 1: Standard commentables
        @target.comments.includes(:user).where(hidden_at: nil)
      end
    end

    def compile_context
      if @target.is_a?(Legislation::QuestionOption)
        # Use question context + add note about filtering
        question_context = self.class.compile_context_for_target(@target.question,
                                                                 comments_count: comments.size)
        filter_note = I18n.t("sensemaker.context.question_option.filter_note", option_value: @target.value)
        "#{question_context}\n\n#{filter_note}"
      elsif @analysable_type == "Proposal" && @analysable_id.nil?
        # Generic "all Proposals" context
        I18n.t("sensemaker.context.proposals.all")
      else
        # Use standard context compilation (Budget, Budget::Group, or other commentables)
        self.class.compile_context_for_target(@target, comments_count: comments.size)
      end
    end

    # Returns a human-readable label for the target
    # Options:
    #   :format - :short (default, for UI display), :full (with class name and ID),
    #             :name_only (just the class name for Class targets)
    def target_label(format: :short)
      if @target.is_a?(Class)
        case format
        when :name_only, :full
          @target.name
        else # :short
          "All #{@target.name.pluralize}"
        end
      elsif @target.respond_to?(:title)
        case format
        when :full
          "#{@target.class.name} #{@target.id}: #{@target.title}"
        else # :short
          @target.title
        end
      elsif @target.respond_to?(:name)
        case format
        when :full
          "#{@target.class.name} #{@target.id}: #{@target.name}"
        else # :short
          @target.name
        end
      else
        # Fallback: use analysable_type
        case format
        when :full
          "#{@analysable_type}#{" #{@analysable_id}" if @analysable_id.present?}"
        else # :short
          @analysable_type
        end
      end
    end

    # Returns a filename-safe label for the target (for file naming)
    def target_filename_label
      if @target.respond_to?(:id)
        "#{@analysable_type}-#{@analysable_id}"
      else
        @analysable_type
      end
    end

    private

      def self.compile_context_for_target(target, comments_count: nil)
        parts = []

        target_type = target.class.name.humanize
        parts << I18n.t("sensemaker.context.base", type: target_type)

        if target.respond_to?(:title)
          parts << I18n.t("sensemaker.context.title", title: target.title)
        elsif target.respond_to?(:name)
          parts << I18n.t("sensemaker.context.name", name: target.name)
        else
          raise "Target #{target.class.name} does not respond to title or name"
        end

        if target.respond_to?(:summary)
          parts << I18n.t("sensemaker.context.summary", summary: target.summary)
        end

        if target.respond_to?(:description) && target.description.present?
          parts << I18n.t("sensemaker.context.description", description: target.description)
        end

        if target.respond_to?(:text) && target.text.present?
          parts << I18n.t("sensemaker.context.text", text: target.text)
        end

        parts.concat(compile_class_specific_context(target))

        parts << "\n--Meta--"
        if target.respond_to?(:geozone) && target.geozone.present?
          parts << I18n.t("sensemaker.context.location", location: target.geozone.name)
        end
        if target.respond_to?(:tag_list) && target.tag_list.any?
          parts << I18n.t("sensemaker.context.tags", tags: target.tag_list.join(", "))
        end
        comment_count = comments_count ||
                        (
                          target.respond_to?(:comments_count) ? target.comments_count : 0
                        ) || 0
        parts << I18n.t("sensemaker.context.comments", count: comment_count)
        parts << I18n.t("sensemaker.context.created", date: target.created_at.strftime("%B %d, %Y"))
        if target.respond_to?(:published?) && target.respond_to?(:published_at) && target.published?
          parts << I18n.t("sensemaker.context.published", date: target.published_at.strftime("%B %d, %Y"))
        end

        parts.join("\n")
      end

      def self.compile_class_specific_context(target)
        parts = []

        case target.class.name
        when "Poll"
          parts << I18n.t("sensemaker.context.poll.questions_header") if target.questions.any?
          target.questions.each do |question|
            parts << I18n.t("sensemaker.context.poll.question_title", title: question.title)
            question.question_options.each do |question_option|
              parts << I18n.t("sensemaker.context.poll.question_option",
                              title: question_option.title,
                              total_votes: question_option.total_votes)
            end
          end
        when "Proposal"
          parts << I18n.t("sensemaker.context.proposal.votes",
                          total_votes: target.total_votes,
                          required_votes: Proposal.votes_needed_for_success)
        when "Debate"
          parts << I18n.t("sensemaker.context.debate.votes",
                          votes_up: target.cached_votes_up,
                          votes_down: target.cached_votes_down)
        when "Legislation::Question"
          parts << I18n.t("sensemaker.context.legislation_question.process",
                          process_title: target.process.title)
          if target.question_options.any?
            parts << I18n.t("sensemaker.context.legislation_question.responses_header")
            target.question_options.each do |option|
              parts << I18n.t("sensemaker.context.legislation_question.option",
                              value: option.value,
                              answers_count: option.answers_count)
            end
          end
        when "Legislation::Proposal"
          parts << I18n.t("sensemaker.context.legislation_proposal.process",
                          process_title: target.process.title)
          parts << I18n.t("sensemaker.context.legislation_proposal.votes",
                          votes_up: target.cached_votes_up,
                          votes_down: target.cached_votes_down)
        when "Budget"
          parts << I18n.t("sensemaker.context.budget.name", name: target.name) if target.respond_to?(:name)
          parts << I18n.t("sensemaker.context.budget.phase",
                          phase: target.phase) if target.respond_to?(:phase)
        when "Budget::Group"
          parts << I18n.t("sensemaker.context.budget_group.name",
                          name: target.name) if target.respond_to?(:name)
          if target.respond_to?(:budget) && target.budget.present?
            parts << I18n.t("sensemaker.context.budget_group.budget",
                            budget_name: target.budget.name)
          end
        end

        parts
      end
  end
end
