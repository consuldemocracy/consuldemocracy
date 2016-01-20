class ProposalFilterOption extends React.Component {
  render() {
    let elemId = `proposal_filter_${this.props.filterGroupName}_${this.props.filterName}`;

    return (
      <div className="field">
        <input
          id={elemId}
          type="checkbox" 
          value="{this.props.filterName}" 
          checked={this.props.checked}
          onChange={(event) => this.props.onChangeFilter(this.props.filterName, event.target.checked)}
        />
        <label htmlFor={elemId}>{this.props.filterLabel || I18n.t(`components.proposal_filter_option.${this.props.filterName}`)}</label> {this.props.children}
      </div>
    );
  }
}
