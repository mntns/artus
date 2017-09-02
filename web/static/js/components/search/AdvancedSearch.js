import React from "react"
import update from 'react-addons-update'; 
import Select from "react-select"
import channel from "../../socket"

import QueryContainer from "./QueryContainer"

class AdvancedSearch extends React.Component {
  constructor() {
    super();
    this.state = {
      filters: []
    }
  }
  addFilter() {
    this.setState({ 
      filters: this.state.filters.concat([{operator: undefined, params: undefined, type: undefined}])
    });
  }
  deleteFilter(id) {
    this.setState({
      filters: update(this.state.filters, {$splice: [[id, 1]]})
    })
  }
  setType(i, type) {
    let updatedFilter = update(this.state.filters[i], {type: {$set: type}});
    this.setState({
      filters: update(this.state.filters, {$splice: [[i, 1, updatedFilter]]})
    });
  }
  handleParams(i, operator, params) {
    let updatedFilter = update(this.state.filters[i], {operator: {$set: operator}, params: {$set: params}});
    this.setState({
      filters: update(this.state.filters, {$splice: [[i, 1, updatedFilter]]})
    });
  }
  runQuery() {
    channel.push("advanced", {filters: this.state.filters})
    .receive("ok", (data) => window.location.href = "/query/" + data.id);
  }
  handleKeyPress(e) {
    if (e.key === 'Enter') {
      this.runQuery();
    }
  }
  render() { 
    return (
        <div onKeyPress={this.handleKeyPress.bind(this)}>
          <h2>Advanced search</h2>
          <br />

          <div className="row">
            <div className="col-md-2">
              <a href="#" role="button" className="btn btn-block btn-primary" onClick={this.addFilter.bind(this)}>
                <i className="fa fa-plus fa-fw"></i> Add filter
              </a>
            </div>
            <div className="col-md-10">
              { this.state.filters.length == 0 ? <div className="alert alert-warning">You haven't selected a filter yet.</div> : ""}
              { this.state.filters.map((item, index) => ( 
                    <QueryContainer key={index} 
                                     id={index} 
                                     paramsHandler={this.handleParams.bind(this)}
                                     deleteHandler={this.deleteFilter.bind(this)} 
                                     typeHandler={this.setType.bind(this)} /> 
                )) }
            </div>
          </div>

          <br />
          
          <a href="#" role="button" onClick={this.runQuery.bind(this)} className="btn btn-lg btn-primary pull-xs-right">
            <i className="fa fa-rocket fa-fw"></i> Run query
          </a>
        </div>
        );
  }
}

export default AdvancedSearch;

