class Admin::Sensemaker::JobRowComponent < ApplicationComponent
  include Admin::Sensemaker::JobComponentHelpers

  attr_reader :job

  def initialize(job)
    @job = job
  end

  def css_classes
    classes = ["job-row"]
    classes << (parent_job? ? "parent-job" : "child-job")
    classes.join(" ")
  end
end
