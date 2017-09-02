import React from "react"
import ReactDOM from "react-dom"

class Operator extends React.Component {
  constructor() {
    super();
    this.state = {
      selectedOperator: "and"
    }
  }
  handleSelect(ce) {
    this.props.callback(ce.target.value);
    this.setState({selectedOperator: ce.target.value});
  }
  render() { 
    return (
        <div className="row">
        <div className="col-md-6"></div>
        <div className="col-md-6">
        <div className="btn-group" id="logicGroup">
        <label className="btn btn-primary active">
        <input type="radio" 
               value="and"
               checked={this.state.selectedOperator === "and"} 
               onChange={this.handleSelect.bind(this)} /> AND
        </label>
        <label className="btn btn-primary">
        <input type="radio" 
               value="or"
               checked={this.state.selectedOperator === "or"} 
               onChange={this.handleSelect.bind(this)} /> OR
        </label>
        <label className="btn btn-primary">
        <input type="radio" 
               value="not"
               checked={this.state.selectedOperator === "not"} 
               onChange={this.handleSelect.bind(this)} /> NOT
        </label>
        <label className="btn btn-primary">
        <input type="radio" 
               value="only"
               checked={this.state.selectedOperator === "only"} 
               onChange={this.handleSelect.bind(this)} /> ONLY
        </label>
        </div>
        </div>
        </div>
        );
  }
}

export default Operator;
