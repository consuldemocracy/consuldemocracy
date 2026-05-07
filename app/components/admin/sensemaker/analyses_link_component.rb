# frozen_string_literal: true

class Admin::Sensemaker::AnalysesLinkComponent < ApplicationComponent
  attr_reader :record

  def initialize(record)
    @record = record
  end

  def render?
    feature?(:sensemaker) && jobs_count.positive?
  end

  def jobs_count
    @jobs_count ||= Sensemaker::Job.for_analysable(record, published_only: false).count
  end

  def link_text
    t("admin.sensemaker.index.sensemaker_analyses_count", count: jobs_count)
  end

  def link_path
    admin_sensemaker_jobs_path(resource_type: admin_resource_type, resource_id: record.id)
  end

  private

    def admin_resource_type
      case record
      when Budget
        "budgets"
      when Debate
        "debates"
      when Proposal
        "proposals"
      when Poll
        "polls"
      when Legislation::Process
        "legislation_processes"
      else
        raise ArgumentError, "Unsupported record type for admin sensemaker link: #{record.class}"
      end
    end
end
