class MeetingProposalsAutocompleteInput extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      proposals: []
    };
  }

  componentDidMount() {
    this.$searchInput = $(this.refs.searchInput);
    this.$searchInput.on('keyup', (event) => { this.onInputChanged(event.currentTarget.value) });
    this.$loading = $(this.refs.loading);
    this.$noResults = $(this.refs.noResults);
    this.$dropdown = $(this.refs.dropdown);

    this.$loading.hide();
    this.$noResults.hide();
    this.$dropdown.hide();
  }

  componentWillUnmount() {
    this.$searchInput.off('keyup');
  }

  render() {
    return (
      <div>
        <input 
          id="proposal_search_input" 
          ref="searchInput" 
          placeholder={ I18n.t("components.meeting_proposals_autocomplete_input.search") } />
        <p ref="loading">{ I18n.t("components.meeting_proposals_autocomplete_input.loading") }</p>
        <p ref="noResults">{ I18n.t("components.meeting_proposals_autocomplete_input.no_results") }</p>
        <ul className="dropdown" ref="dropdown">
          {
            this.state.proposals.map((proposal) => {
              return (
                <li key={proposal.id}><a onClick={(event) => this.onClickProposal(proposal)}>{proposal.title}</a></li>
              );
            })
          }
        </ul>
      </div>
    );
  }

  onInputChanged (text) {
    if (this.searchTimeoutId) {
      clearTimeout(this.searchTimeoutId);
    }

    this.searchTimeoutId = setTimeout(() => {
      this.search(text);
    }, 300);
  }

  search(text) {
    this.$noResults.hide();
    if (text.length > 0) {
      this.$loading.show();
      this.$dropdown.hide();

      $.ajax({
        url: this.props.proposalsApiUrl,
        method: 'GET',
        data: {
          search: text,
          exclude_ids: this.props.excludeIds
        }
      }).then(({ proposals } ) => {
        this.$loading.hide();
        if (proposals.length > 0) {
          this.$dropdown.show();
          this.setState({ proposals })
        } else {
          this.$noResults.show();
        }
      });
    }
  }

  onClickProposal(proposal) {
    this.$searchInput.val('');
    this.$searchInput.focus();
    this.$dropdown.hide();
    this.props.onAddProposal(proposal);
  }
}
