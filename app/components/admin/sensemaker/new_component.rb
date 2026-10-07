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

  def script_options
    Sensemaker::ScriptRegistry.user_selectable.map do |script|
      key = Sensemaker::ScriptRegistry.i18n_key(script)
      [I18n.t("admin.sensemaker.scripts.#{key}.title"), script]
    end
  end
end
