class DistrictFilterOptionGroup extends React.Component {
  render() {
    if (this.props.scopeSelected && this.props.scopeSelected.indexOf("district") !== -1) {
      return (
        <FilterOptionGroup 
          condition={this.props.condition}
          filterGroupName="district" 
          filterGroupValue={this.props.filterGroupValue}
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.props.onChangeFilterGroup(filterGroupName, filterGroupValue) }>
          {
            this.props.districts.map(function (district) {
              return <FilterOption key={district[1]} filterName={district[1]} filterLabel={district[0]} />
            })
          }
        </FilterOptionGroup>
      )
    }
    return null;
  }
}
