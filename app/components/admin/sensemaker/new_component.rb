class Admin::Sensemaker::NewComponent < ApplicationComponent
  include Header
  attr_reader :sensemaker_job

  def initialize(sensemaker_job, search_results)
    @sensemaker_job = sensemaker_job
    @search_results = search_results
    @query_types = [
      "Debate",
      "Proposal",
      "Poll",
      "Topic",
      "Legislation::Process"
    ]
  end

  def title
    t("admin.sensemaker.new.title")
  end
end
