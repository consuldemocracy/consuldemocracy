class DistrictFilterOptionGroup extends React.Component {
  render() {
    return (
      <ProposalFilterOptionGroup 
        condition={this.props.condition}
        filterGroupName="district" 
        filterGroupValue={this.props.filterGroupValue}
        onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.props.onChangeFilterGroup(filterGroupName, filterGroupValue) }>
        {
          this.props.districts.map(function (district) {
            return <ProposalFilterOption key={district[1]} filterName={district[1]} filterLabel={district[0]} />
          })
        }
      </ProposalFilterOptionGroup>
    )
  }
}
