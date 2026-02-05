class Sensemaker::JobCardComponent < ApplicationComponent
  include Sensemaker::ReportComponentHelpers

  attr_reader :job

  def initialize(job)
    @job = job
  end
end
