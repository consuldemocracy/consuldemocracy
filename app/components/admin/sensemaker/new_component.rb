class Admin::Sensemaker::NewComponent < ApplicationComponent
  include Header

  attr_reader :sensemaker_job

  def initialize(sensemaker_job, search_results, result_count)
    @sensemaker_job = sensemaker_job
    @search_results = search_results
    @result_count = result_count
    @query_types = [
      "Debate",
      "Proposal",
      "Poll",
      "Legislation::Process",
      "Budget"
    ]
  end

  def title
    t("admin.sensemaker.new.title")
  end
end
