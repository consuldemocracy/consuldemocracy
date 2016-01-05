class ProposalFilterOptionGroup extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filterGroupValue: Immutable.Set(this.props.filterGroupValue)
    };
  }

  renderChildren() {
    return React.Children.map(this.props.children, (child) => {
      return React.cloneElement(child, {
        filterGroupName: this.props.filterGroupName,
        onChangeFilter: (filterName, filterValue) => this.changeFilter(filterName, filterValue),
        checked: this.state.filterGroupValue.has(child.props.filterName)
      })
    });
  }

  render() {
    return (
      <div>
        <h3>{I18n.t(`components.proposal_filter_option_group.${this.props.filterGroupName}`)}</h3>
        {this.renderChildren()}
      </div>
    );
  }

  changeFilter(filterName, isChecked) {
    let filterGroupValue = this.state.filterGroupValue;

    if (this.props.isExclusive) {
      filterGroupValue = filterGroupValue.clear();
    }

    if (isChecked) {
      filterGroupValue = filterGroupValue.add(filterName);
    } else {
      filterGroupValue = filterGroupValue.delete(filterName);
    }

    this.setState({ filterGroupValue });
    this.props.onChangeFilterGroup(this.props.filterGroupName, filterGroupValue.toArray());
  }
}
