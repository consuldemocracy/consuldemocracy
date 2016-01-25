class ScopeFilterOptionGroup extends React.Component {
  render() {
    return (
        <ProposalFilterOptionGroup 
          filterGroupName="scope" 
          filterGroupValue={this.props.filterGroupValue}
          isExclusive={true}
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.props.onChangeFilterGroup(filterGroupName, filterGroupValue) }>
          <ProposalFilterOption filterName="city" />
          <ProposalFilterOption filterName="district" />
        </ProposalFilterOptionGroup>
    )
  }
}
