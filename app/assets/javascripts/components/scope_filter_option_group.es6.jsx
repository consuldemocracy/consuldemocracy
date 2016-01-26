class ScopeFilterOptionGroup extends React.Component {
  render() {
    return (
        <FilterOptionGroup 
          filterGroupName="scope" 
          filterGroupValue={this.props.filterGroupValue}
          isExclusive={true}
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.props.onChangeFilterGroup(filterGroupName, filterGroupValue) }>
          <FilterOption filterName="city" />
          <FilterOption filterName="district" />
        </FilterOptionGroup>
    )
  }
}
