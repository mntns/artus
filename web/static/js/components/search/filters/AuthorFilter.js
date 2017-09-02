import React from "react"

class AuthorFilter extends React.Component {
  constructor() {
    super();
    this.state = {
      author: ""
    }
  }
  handleChange(e) {
    this.setState({author: e.target.value});
    this.props.callback({author: e.target.value});
  }
  render() { 
    return (
        <div>
    <div className="form-group row">
      <label htmlFor="from" className="col-sm-2 col-form-label">Name of the author</label>
        <div className="col-md-10">
        <input placeholder="Name of the author" className="form-control" type="text" id="author" value={this.state.author} onChange={this.handleChange.bind(this)} />
        </div>
    </div>
    </div>
        );
  }
}

export default AuthorFilter;
