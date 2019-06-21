module ReportAttributes
  extend ActiveSupport::Concern

  private

    def report_attributes
      Report::KINDS.map { |kind| :"#{kind}_enabled" }
    end
end
