class Debate::Exporter
  include CsvExporter

  attr_reader :records

  def initialize(debates)
    @records = debates
  end

  private

    def headers
      [
        I18n.t("admin.debates.index.id"),
        Debate.human_attribute_name(:title),
        I18n.t("admin.debates.index.author"),
        Debate.human_attribute_name(:created_at)
      ]
    end

    def csv_values(debate)
      [
        debate.id.to_s,
        debate.title,
        debate.author.email,
        I18n.l(debate.created_at, format: :datetime)
      ]
    end
end
