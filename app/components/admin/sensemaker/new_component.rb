class Admin::Sensemaker::NewComponent < ApplicationComponent
  include Header
  attr_reader :sensemaker_job

  def initialize(sensemaker_job)
    @sensemaker_job = sensemaker_job
  end

  def title
    t("admin.sensemaker.new.title")
  end
end
