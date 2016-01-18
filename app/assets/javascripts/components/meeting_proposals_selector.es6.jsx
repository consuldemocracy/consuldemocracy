class MeetingProposalsSelector extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      proposals: Immutable.Set(this.props.proposals)
    };
  }
  render() {
    return (
      <div className="meeting_proposals_selector">
        <input type="hidden" name="meeting[proposal_ids][]" value="" />
        {
          this.state.proposals.map((proposal) => {
            return (
              <input key={proposal.id} type="hidden" name="meeting[proposal_ids][]" value={proposal.id} />
            )
          })
        }
        <MeetingProposalsAutocompleteInput 
          proposalsApiUrl={this.props.proposals_api_url}
          excludeIds={this.state.proposals.map((proposal) => proposal.id).toArray()}
          onAddProposal={(proposal) => this.addProposal(proposal)} />
        <MeetingProposalsTable 
          proposals={this.state.proposals} 
          onRemoveProposal={(proposal) => this.removeProposal(proposal)} />
      </div>
    );
  }

  addProposal(proposal) {
    let proposals = this.state.proposals.add(proposal);
    this.setState({ proposals })
  }

  removeProposal(proposal) {
    let proposals = this.state.proposals.delete(proposal);
    this.setState({ proposals })
  }
}
