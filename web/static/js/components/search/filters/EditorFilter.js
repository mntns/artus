import React from "react"

class EditorFilter extends React.Component {
  constructor() {
    super();
    this.state = {
      editor: ""
    }
  }
  handleChange(e) {
    this.setState({editor: e.target.value});
    this.props.callback({editor: e.target.value});
  }
  render() { 
    return (
        <div>
    <div className="form-group row">
      <label htmlFor="from" className="col-sm-2 col-form-label">Name of the editor</label>
        <div className="col-md-10">
        <input placeholder="Name of the editor" className="form-control" type="text" id="editor" value={this.state.editor} onChange={this.handleChange.bind(this)} />
        </div>
    </div>
    </div>
        );
  }
}

export default EditorFilter;
