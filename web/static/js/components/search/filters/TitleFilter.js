import React from "react"

class TitleFilter extends React.Component {
  constructor() {
    super();
    this.state = {
      title: ""
    }
  }
  handleChange(e) {
    this.setState({title: e.target.value});
    this.props.callback({title: e.target.value});
  }
  render() { 
    return (
        <div>
    <div className="form-group row">
        <div className="col-md-12">
        <input placeholder="Title" className="form-control" type="text" id="title" value={this.state.title} onChange={this.handleChange.bind(this)} />
        </div>
    </div>
    </div>
        );
  }
}

export default TitleFilter;
