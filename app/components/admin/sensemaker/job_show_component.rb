class Admin::Sensemaker::JobShowComponent < ApplicationComponent
  include Admin::Sensemaker::JobComponentHelpers
  include Header

  attr_reader :sensemaker_job, :child_jobs

  def initialize(sensemaker_job, child_jobs)
    @sensemaker_job = sensemaker_job
    @child_jobs = child_jobs
  end

  def job
    sensemaker_job
  end

  def title
    "Sensemaker Job ##{sensemaker_job.id}"
  end

  def enabled?
    feature?(:sensemaker)
  end

  def has_children?
    child_jobs.any?
  end

  def topic_stats_path
    sensemaker_job.output_artifact_paths.find { |p| p.end_with?("-topic-stats.json") }
  end

  def summary_path
    sensemaker_job.output_artifact_paths.find { |p| p.end_with?("-summary.json") }
  end
end
