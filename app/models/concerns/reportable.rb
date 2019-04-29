module Reportable
  extend ActiveSupport::Concern

  included do
    has_one :report, as: :process, dependent: :destroy
    accepts_nested_attributes_for :report
  end

  def report
    super || build_report
  end

  def results_enabled?
    report&.results?
  end
  alias_method :results_enabled, :results_enabled?

  def stats_enabled?
    report&.stats?
  end
  alias_method :stats_enabled, :stats_enabled?

  def results_enabled=(enabled)
    report.results = enabled
  end

  def stats_enabled=(enabled)
    report.stats = enabled
  end
end
