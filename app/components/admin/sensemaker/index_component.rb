class Admin::Sensemaker::IndexComponent < ApplicationComponent
  include Header

  attr_reader :sensemaker_jobs, :running_jobs

  def initialize(sensemaker_jobs, running_jobs)
    @sensemaker_jobs = sensemaker_jobs
    @running_jobs = running_jobs
  end

  def title
    t("admin.sensemaker.index.title")
  end

  def enabled?
    feature?(:sensemaker)
  end
end
