# frozen_string_literal: true

class Conversation
  CommentLikeItem = Data.define(:id, :body, :cached_votes_up, :cached_votes_down, :cached_votes_total,
                                :user_id)

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

  def context_i18n_scope
    "conversation.context"
  end

  def comments
    if @target.is_a?(Legislation::QuestionOption)
      user_ids = @target.answers.pluck(:user_id)
      if user_ids.any?
        @target.question.comments.includes(:user).where(hidden_at: nil, user_id: user_ids)
      else
        Comment.none
      end
    elsif @target.is_a?(Budget) || @target.is_a?(Budget::Group)
      investments = @target.investments.includes(:author).where(hidden_at: nil)
      investments.map do |investment|
        CommentLikeItem.new(
          id: investment.id,
          body: "#{investment.title}\n\n#{self.class.sanitize_html(investment.description)}",
          cached_votes_up: 1 + investment.cached_votes_up,
          cached_votes_down: 0,
          cached_votes_total: 1 + investment.cached_votes_up,
          user_id: investment.author_id
        )
      end
    elsif @analysable_type == "Proposal" && @analysable_id.nil?
      proposals = Proposal.includes(:author).where(hidden_at: nil)
      proposals.map do |proposal|
        CommentLikeItem.new(
          id: proposal.id,
          body: "#{proposal.title}\n\n#{self.class.sanitize_html(proposal.description)}",
          cached_votes_up: 1 + proposal.cached_votes_up,
          cached_votes_down: 0,
          cached_votes_total: 1 + proposal.cached_votes_up,
          user_id: proposal.author_id
        )
      end
    elsif @target.is_a?(Poll) && @target.questions.any?(&:open?)
      all_answers = @target.answers
                           .includes(:author, :option, question: [:question_options, :votation_type])
                           .group_by(&:author_id)
      return [] if all_answers.empty?

      all_answers.map do |user_id, user_answers|
        answer_parts = []

        @target.questions.each_with_index do |question, index|
          question_answers = user_answers.select { |answer| answer.question_id == question.id }
          next if question_answers.empty?

          question_number = index + 1
          formatted_answer = format_user_answer_for_question(question, question_answers)
          answer_parts << "Q#{question_number}: #{formatted_answer}"
        end

        next if answer_parts.empty?

        CommentLikeItem.new(
          id: "combined_answers_#{user_id}",
          body: answer_parts.join(" | "),
          cached_votes_up: 1,
          cached_votes_down: 0,
          cached_votes_total: 1,
          user_id: user_id
        )
      end.compact
    elsif @target.is_a?(Poll::Question)
      question = Poll::Question
                 .includes(:question_options, :votation_type, answers: :author, partial_results: :option)
                 .find(@target.id)

      unless question.open?
        question_type = question.multiple? ? "multiple choice" : "single choice"
        raise ArgumentError,
              "Sensemaker analysis is only supported for open-ended Poll::Question. " \
              "This question is #{question_type}."
      end

      question.answers.includes(:author).map do |answer|
        CommentLikeItem.new(
          id: "a_#{answer.id}",
          body: answer.answer.to_s,
          cached_votes_up: 1,
          cached_votes_down: 0,
          cached_votes_total: 1,
          user_id: answer.author_id
        )
      end
    else
      @target.comments.includes(:user).where(hidden_at: nil)
    end
  end

  def compile_context
    scope = context_i18n_scope
    if @target.is_a?(Legislation::QuestionOption)
      question_context = self.class.compile_context_for_target(@target.question,
                                                               i18n_scope: scope,
                                                               comments_count: comments.size)
      filter_note = I18n.t("#{scope}.question_option.filter_note", option_value: @target.value)
      "#{question_context}\n\n#{filter_note}"
    elsif @target.is_a?(Poll::Question)
      poll_context = self.class.compile_context_for_target(@target.poll,
                                                           i18n_scope: scope,
                                                           comments_count: comments.size)
      poll_note = I18n.t("#{scope}.poll_question.filter_note", question_title: @target.title)
      "#{poll_context}\n\n#{poll_note}"
    elsif @analysable_type == "Proposal" && @analysable_id.nil?
      I18n.t("#{scope}.proposals.all")
    else
      self.class.compile_context_for_target(@target, i18n_scope: scope, comments_count: comments.size)
    end
  end

  def target_label(format: :short)
    if @target.is_a?(Poll::Question)
      case format
      when :full
        "Poll::Question #{@target.id}: #{@target.title}"
      else
        @target.title
      end
    elsif @target.is_a?(Class)
      case format
      when :name_only, :full
        @target.name
      else
        "All #{@target.name.pluralize}"
      end
    elsif @target.respond_to?(:title)
      case format
      when :full
        "#{@target.class.name} #{@target.id}: #{@target.title}"
      else
        @target.title
      end
    elsif @target.respond_to?(:name)
      case format
      when :full
        "#{@target.class.name} #{@target.id}: #{@target.name}"
      else
        @target.name
      end
    elsif @target.respond_to?(:value)
      case format
      when :full
        "#{@target.class.name} #{@target.id}: #{@target.value}"
      else
        @target.value
      end
    else
      case format
      when :full
        "#{@analysable_type}#{" #{@analysable_id}" if @analysable_id.present?}"
      else
        @analysable_type
      end
    end
  end

  def target_filename_label
    if @target.respond_to?(:id)
      "#{@analysable_type}-#{@analysable_id}"
    else
      @analysable_type
    end
  end

  def self.sanitize_html(text)
    return "" if text.blank?

    decoded = Nokogiri::HTML.fragment(text.to_s).text
    decoded.squish
  end

  def self.compile_context_for_target(target, i18n_scope:, comments_count: nil)
    parts = []

    target_type = I18n.t("#{i18n_scope}.type.#{target.class.name.underscore}")
    parts << I18n.t("#{i18n_scope}.base", type: target_type)

    if target.respond_to?(:title)
      parts << I18n.t("#{i18n_scope}.title", title: target.title)
    elsif target.respond_to?(:name)
      parts << I18n.t("#{i18n_scope}.name", name: target.name)
    else
      raise "Target #{target.class.name} does not respond to title or name"
    end

    if target.respond_to?(:summary)
      parts << I18n.t("#{i18n_scope}.summary", summary: sanitize_html(target.summary))
    end

    if target.respond_to?(:description) && target.description.present?
      parts << I18n.t("#{i18n_scope}.description", description: sanitize_html(target.description))
    end

    if target.respond_to?(:text) && target.text.present?
      parts << I18n.t("#{i18n_scope}.text", text: sanitize_html(target.text))
    end

    parts.concat(compile_class_specific_context(target, i18n_scope: i18n_scope))

    parts << "\n## Meta"
    if target.respond_to?(:geozone) && target.geozone.present?
      parts << I18n.t("#{i18n_scope}.location", location: target.geozone.name)
    end
    if target.respond_to?(:tag_list) && target.tag_list.any?
      parts << I18n.t("#{i18n_scope}.tags", tags: target.tag_list.join(", "))
    end
    comment_count = comments_count ||
                    (
                      target.respond_to?(:comments_count) ? target.comments_count : 0
                    ) || 0
    parts << I18n.t("#{i18n_scope}.comments", count: comment_count)
    parts << I18n.t("#{i18n_scope}.created", date: target.created_at.strftime("%B %d, %Y"))
    if target.respond_to?(:published?) && target.respond_to?(:published_at) && target.published?
      parts << I18n.t("#{i18n_scope}.published", date: target.published_at.strftime("%B %d, %Y"))
    end

    parts.join("\n")
  end

  def self.compile_class_specific_context(target, i18n_scope:)
    parts = []

    case target.class.name
    when "Poll"
      if target.questions.any?
        parts << I18n.t("#{i18n_scope}.poll.questions_header",
                        count: target.questions.count)
        target.questions.each_with_index do |question, index|
          question_type_label = if question.open?
                                  I18n.t("#{i18n_scope}.poll.question_type.open_ended")
                                elsif question.multiple?
                                  I18n.t("#{i18n_scope}.poll.question_type.multiple_choice")
                                else
                                  I18n.t("#{i18n_scope}.poll.question_type.unique_choice")
                                end
          parts << I18n.t("#{i18n_scope}.poll.question_with_type",
                          number: index + 1,
                          type: question_type_label,
                          title: question.title)
          if question.accepts_options? && question.question_options.any?
            question.question_options.each_with_index do |question_option, opt_index|
              parts << I18n.t("#{i18n_scope}.poll.question_option_with_votes",
                              number: opt_index + 1,
                              title: question_option.title,
                              votes: question_option.total_votes)
            end
          end
        end

        if target.questions.any?(&:open?)
          parts << I18n.t("#{i18n_scope}.poll.combined_answers_note")
        end
      end
    when "Poll::Question"
      parts << I18n.t("#{i18n_scope}.poll_question.question_title", title: target.title)
      if target.accepts_options? && target.question_options.any?
        target.question_options.each_with_index do |question_option, opt_index|
          parts << I18n.t("#{i18n_scope}.poll.question_option",
                          number: opt_index + 1,
                          title: question_option.title)
        end
      elsif target.open?
        parts << I18n.t("#{i18n_scope}.poll_question.open_ended",
                        answers_count: target.answers.count)
      end
    when "Proposal"
      parts << I18n.t("#{i18n_scope}.proposal.votes",
                      total_votes: target.total_votes,
                      required_votes: Proposal.votes_needed_for_success)
    when "Debate"
      parts << I18n.t("#{i18n_scope}.debate.votes",
                      votes_up: target.cached_votes_up,
                      votes_down: target.cached_votes_down)
    when "Legislation::Question"
      parts << I18n.t("#{i18n_scope}.legislation_question.process",
                      process_title: target.process.title)
      if target.question_options.any?
        parts << I18n.t("#{i18n_scope}.legislation_question.responses_header")
        target.question_options.each do |option|
          parts << I18n.t("#{i18n_scope}.legislation_question.option",
                          value: option.value,
                          answers_count: option.answers_count)
        end
      end
    when "Legislation::Proposal"
      parts << I18n.t("#{i18n_scope}.legislation_proposal.process",
                      process_title: target.process.title)
      parts << I18n.t("#{i18n_scope}.legislation_proposal.votes",
                      votes_up: target.cached_votes_up,
                      votes_down: target.cached_votes_down)
    when "Budget"
      parts << I18n.t("#{i18n_scope}.budget.name", name: target.name) if target.respond_to?(:name)
      parts << I18n.t("#{i18n_scope}.budget.phase",
                      phase: target.phase) if target.respond_to?(:phase)
    when "Budget::Group"
      parts << I18n.t("#{i18n_scope}.budget_group.name",
                      name: target.name) if target.respond_to?(:name)
      if target.respond_to?(:budget) && target.budget.present?
        parts << I18n.t("#{i18n_scope}.budget_group.budget",
                        budget_name: target.budget.name)
      end
    end

    parts
  end

  private

    def format_user_answer_for_question(question, user_answers)
      if question.open?
        user_answers.first.answer.to_s
      elsif question.accepts_options? && question.question_options.any?
        selected_options = user_answers.map { |answer| answer.option&.title }.compact
        selected_options.join(", ")
      else
        ""
      end
    end
end
