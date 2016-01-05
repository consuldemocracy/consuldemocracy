class ProposalFilterOption extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className="field">
        <input 
          type="checkbox" 
          value="program" 
          onChange={(event) => this.props.onChangeFilter(this.props.filterName, event.target.checked)}
        />
        <label>{this.props.filterName}</label>
      </div>
    );
  }
}

class ProposalFilterOptionGroup extends React.Component {
  constructor(props) {
    super(props);

    this.childrenFilterNames = this.props.children.map((child) => child.props.filterName);
  }

  renderChildren() {
    return React.Children.map(this.props.children, (child) => {
      return React.cloneElement(child, {
        onChangeFilter: (filterName, filterValue) => this.changeFilter(filterName, filterValue)
      })
    });
  }

  render() {
    return (
      <div>
        <h3>{this.props.filterGroupName}</h3>
        {this.renderChildren()}
      </div>
    );
  }

  changeFilter(filterName, filterValue) {
    let filterGroupValue;

    filterGroupValue = this.childrenFilterNames.reduce(function (result, name) {
      result[name] = false;
      return result;
    }, {});

    filterGroupValue[filterName] = filterValue;

    this.props.onChangeFilterGroup(this.props.filterGroupName, filterGroupValue);
  }
}

class ProposalFilters extends React.Component {
  constructor(props) {
    super(props);
    this.filters = {};
  }

  render() {
    return (
      <form>
        <ProposalFilterOptionGroup 
          filterGroupName="origin" 
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.changeFilterGroup(filterGroupName, filterGroupValue) }>
          <ProposalFilterOption filterName="program" />
          <ProposalFilterOption filterName="citizenship" />
        </ProposalFilterOptionGroup>
        <ProposalFilterOptionGroup 
          filterGroupName="featured" 
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.changeFilterGroup(filterGroupName, filterGroupValue) }>
          <ProposalFilterOption filterName="innovative" />
          <ProposalFilterOption filterName="priority" />
        </ProposalFilterOptionGroup>
      </form>
    );
  }

  changeFilterGroup(filterGroupName, filterGroupValue) {
    this.filters[filterGroupName] = filterGroupValue;
    console.log(`Filter updated!`);
    console.log(this.filters);
  }
}
