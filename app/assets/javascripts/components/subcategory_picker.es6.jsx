class SubcategoryPicker extends React.Component {
  subcategories () {
    var categoryId = this.props.categoryId;
    var subcategories = this.props.subcategories.filter( (subcategory) =>
      subcategory.categoryId === categoryId
    );

    var selectedId = this.props.selectedId;
    var component = this;

    return subcategories.map( function(subcategory){
      var selected = subcategory.id === selectedId;

      return (
        <li
            key={subcategory.id}
            onClick={() => component.select(subcategory)}
            className={selected ? 'selected' : ''}
        >
          {subcategory.name}
          <p>{subcategory.description}</p>
        </li>
      );
    });
  }

  render () {
    return (
      <div className="subcategory-picker">
        <label>{I18n.t("components.category_picker.subcategory.label")}</label>
        <ul>
          {this.subcategories()}
        </ul>
      </div>
    );
  }

  select (subcategory) {
    if (this.props.onSelect) {
      this.props.onSelect(subcategory)
    }
  }
}
