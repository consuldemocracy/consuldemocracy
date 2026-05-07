# frozen_string_literal: true

module Sensemaker
  module ResourceTypeResolution
    extend ActiveSupport::Concern

    SENSEMAKER_RESOURCE_TYPES = %w[
      budgets
      debates
      proposals
      polls
      poll_questions
      legislation_processes
      legislation_questions
      legislation_proposals
      legislation_question_options
    ].freeze

    def sensemaker_model_for_resource_type(resource_type)
      case resource_type.to_s
      when "budgets"
        Budget
      when "debates"
        Debate
      when "proposals"
        Proposal
      when "polls"
        Poll
      when "poll_questions"
        Poll::Question
      when "legislation_processes"
        Legislation::Process
      when "legislation_questions"
        Legislation::Question
      when "legislation_proposals"
        Legislation::Proposal
      when "legislation_question_options"
        Legislation::QuestionOption
      else
        nil
      end
    end

    def sensemaker_find_resource(resource_type, resource_id)
      model = sensemaker_model_for_resource_type(resource_type)
      return nil unless model

      if model == Budget
        model.find_by_slug_or_id(resource_id)
      else
        model.find(resource_id)
      end
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end
