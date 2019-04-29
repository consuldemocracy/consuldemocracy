module Reportable
  extend ActiveSupport::Concern

  included do
    has_one :report, as: :process, dependent: :destroy
    accepts_nested_attributes_for :report
  end

  def report
    super || build_report
  end

  Report::KINDS.each do |kind|
    define_method "#{kind}_enabled?" do
      report.send(kind)
    end
    alias_method "#{kind}_enabled", "#{kind}_enabled?"

    define_method "#{kind}_enabled=" do |enabled|
      report.send("#{kind}=", enabled)
    end
  end
end
