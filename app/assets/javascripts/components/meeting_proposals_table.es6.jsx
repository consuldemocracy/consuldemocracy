class MeetingProposalsTable extends React.Component {
  render() {
    return (
      <table>
        <thead>
          <tr>
            <th>{I18n.t("components.meeting_proposals_table.title")}</th>
            <th>{I18n.t("components.meeting_proposals_table.actions")}</th>
          </tr>
        </thead>
        <tbody>
          {
            this.props.proposals.map((proposal) => {
              return (
                <tr key={proposal.id}>
                  <td>{proposal.title}</td>
                  <td>
                    <button onClick={(event) => this.props.onRemoveProposal(proposal) }>
                      {I18n.t("components.meeting_proposals_table.remove")}
                    </button>
                  </td>
                </tr>
              )
            })
          }
        </tbody>
      </table>
    );
  }
}
