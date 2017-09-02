import React from "react"

class YearFilter extends React.Component {
  constructor() {
    super();
    this.state = {
      from: 0,
      to: 0
    }
  }
  handleFrom(e) {
    this.setState({from: e.target.value});
    this.props.callback({from: e.target.value, to: this.state.to});
  }
  handleTo(e) {
    this.setState({to: e.target.value});
    this.props.callback({from: this.state.from, to: e.target.value});
  }
  render() { 
    return (
        <div>
    <div className="form-group row">
      <label htmlFor="from" className="col-sm-2 col-form-label">From</label>
        <div className="col-md-10">
        <input placeholder="Start of range" className="form-control" type="year" id="from" value={this.state.from} onChange={this.handleFrom.bind(this)} />
        </div>
    </div>
    <div className="form-group row">
      <label htmlFor="to" className="col-sm-2 col-form-label">To</label>
        <div className="col-md-10">
        <input placeholder="End of range" className="form-control" type="year" id="to" value={this.state.to} onChange={this.handleTo.bind(this)} />
        </div>
    </div>
    </div>
        );
  }
}

export default YearFilter;
