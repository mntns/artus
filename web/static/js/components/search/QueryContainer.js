import React from "react"
import Select from "react-select"
import update from 'react-addons-update'

import FilterElement from "./FilterElement"

var options = [
    { value: 'title', label: 'Title' },
    { value: 'lang', label: 'Language' },
    { value: 'year', label: 'Year of Publication' },
    { value: 'author', label: 'Author of Publication' },
    { value: 'editor', label: 'Editor of Publication' }
];

class QueryContainer extends React.Component {
  constructor() {
    super();
    this.state = {
      type: undefined,
      chosen: false,
      tree: {}
    }
  }
  chooseType(type) {
    this.props.typeHandler(this.props.id, type.value);
    this.setState({type: type.value, chosen: true});
  }
  render() { 
    return (
        <div className="filter-row">
          <div className="card">
            <div className="card-header">
              <div className="row">
                <div className="col-md-9">
                  <Select name="form-field-name" value="one" disabled={this.state.chosen} options={options} value={this.state.type} onChange={this.chooseType.bind(this)} />
                </div>
                <div className="col-md-3">
                  <a href="#" className="btn btn-danger btn-block" onClick={() => this.props.deleteHandler(this.props.id)}>
                  <i className="fa fa-close" aria-hidden="true"></i> Remove filter
                  </a>
                </div>
              </div>
            </div>
              {this.state.type ? 
            <div className="card-block">
              <FilterElement type={this.state.type} elementID={this.props.id} propagateParams={this.props.paramsHandler} /> 
            </div> : null}
          </div>
        </div>
        );
  }
}

export default QueryContainer;
