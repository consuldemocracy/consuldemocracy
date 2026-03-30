class Debate::Exporter
  include CsvExporter

  attr_reader :records

  def initialize(debates)
    @records = debates
  end

  private

    def headers
      [
        I18n.t("admin.debates.index.list.id"),
        I18n.t("admin.debates.index.list.title"),
        I18n.t("admin.debates.index.list.author")
      ]
    end

    def csv_values(debate)
      [
        debate.id.to_s,
        debate.title,
        debate.author.email
      ]
    end
end
