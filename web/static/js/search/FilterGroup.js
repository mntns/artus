import React from "react"
import FilterContainer from "./FilterContainer"

class FilterGroup extends React.Component {
  constructor() {
    super();
    this.state = {
      operator: "and",
      elements: []
    };
  }
  handleOperatorSelect(event) {
    switch (event.target.innerText) {
      case "OR":
        this.setState({operator: "or"});
        break;
      case "AND":
        this.setState({operator: "and"});
        break;
    }
  }
  addFilter() {
    this.setState({elements: this.state.elements.concat(["filter"])});
  }
  addGroup() {
    this.setState({elements: this.state.elements.concat(["group"])});
  }
  render() {
    return (
      <div className="card">
        <div className="card-header nav">
            <div className="btn-group mr-auto" role="group" aria-label="Basic example">
              <button onClick={this.handleOperatorSelect.bind(this)} 
                      type="button" 
                      className={"btn btn-primary " + (this.state.operator == "and" ? "active" : "")}>AND</button>
              <button onClick={this.handleOperatorSelect.bind(this)} 
                      type="button" 
                      className={"btn btn-primary " + (this.state.operator == "or" ? "active" : "")}>OR</button>
            </div>
            <div className="btn-group ml-auto" role="group" aria-label="Basic example">
              <button onClick={this.addGroup.bind(this)} type="button" className="btn btn-primary">Add group</button>
              <button onClick={this.addFilter.bind(this)} type="button" className="btn btn-primary">Add filter</button>
              <button type="button" className="btn btn-danger">Delete</button>
            </div>
        </div>
        <div className="card-body">
          {this.state.elements.map(function(element, i){
            switch (element) {
              case "filter":
                  return <FilterContainer key={i} />
                  break;

              case "group":
                  return <FilterGroup key={i} />
                  break;
            }
          })}
        </div>
      </div>
    )
  }
}

export default FilterGroup;
