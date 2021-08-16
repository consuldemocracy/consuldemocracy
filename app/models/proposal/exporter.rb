class Proposal::Exporter
  include JsonExporter

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
end
