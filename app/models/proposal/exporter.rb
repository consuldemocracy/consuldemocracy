class Proposal::Exporter
  include CsvExporter
  include JsonExporter

  attr_reader :records

  def initialize(proposals)
    @records = proposals
  end

  def model
    Proposal
  end

  private

    def json_values(proposal)
      {
        id: proposal.id,
        title: proposal.title,
        summary: strip_tags(proposal.summary),
        description: strip_tags(proposal.description)
      }
    end

    def headers
      [
        I18n.t("admin.proposals.index.list.id"),
        I18n.t("admin.proposals.index.list.title"),
        I18n.t("admin.proposals.index.list.author"),
        I18n.t("admin.proposals.index.list.summary")
      ]
    end

    def csv_values(proposal)
      [
        proposal.id.to_s,
        proposal.title,
        proposal.author.email,
        proposal.summary
      ]
    end
end
