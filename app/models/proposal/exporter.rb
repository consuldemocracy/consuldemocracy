class Proposal::Exporter
  include CsvExporter

  attr_reader :records

  def initialize(proposals)
    @records = proposals
  end

  private

    def model_headers
      [
        I18n.t("admin.proposals.index.list.id"),
        I18n.t("admin.proposals.index.list.title"),
        I18n.t("admin.proposals.index.list.author"),
        I18n.t("admin.proposals.index.list.summary"),
        Proposal.human_attribute_name(:created_at)
      ]
    end

    def record_csv_values(proposal)
      [
        proposal.id.to_s,
        proposal.title,
        proposal.author.email,
        proposal.summary,
        I18n.l(proposal.created_at, format: :datetime)
      ]
    end
end
