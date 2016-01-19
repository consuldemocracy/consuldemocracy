class CategoryPicker extends React.Component {
  render () {
    var selectedId = this.props.selectedId;
    var category = this.props.categories.map(category => this.renderRow(category));

    return (
      <div className="category-picker">
        <label>{I18n.t("components.category_picker.category.label")}</label>
        <ul>{category}</ul>
      </div>
    );
  }

  renderRow (category) {
    var selected = this.props.selectedId === category.id;
    var name = category.name;

    var classNames = ['category-' + category.id];
    if(selected){ classNames.push('selected'); }

    return (
      <li className={classNames.join(' ')}
          key={category.id}
          onClick={() => this.selectCategory(category)}>
        <span className="category">{name}</span>
      </li>
    );
  }

  selectCategory(category){
    if(this.props.onSelect){
      this.props.onSelect(category);
    }
  }
}
