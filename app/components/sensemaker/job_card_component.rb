class Sensemaker::JobCardComponent < ApplicationComponent
  include Sensemaker::ReportComponentHelpers

  attr_reader :job

  def initialize(job)
    @job = job
  end

  def unpublished?
    !job.published?
  end

  def unpublished_badge_text
    t("sensemaker.job_index.unpublished")
  end
end
