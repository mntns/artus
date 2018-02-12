import React from "react"
import {LabelPill} from "./Helpers"
import HelpButton from "./HelpButton"

class AbstractInput extends React.Component {
  constructor() {
    super();
    this.state = {
      text: "",
      count: 0,
      limit: 50
    }
  }
  componentDidMount() {
    // TODO: Set limit according to type
    //if (this.props.type == "b")
    //  this.setState({limit: 100})
  }
  handleChange(e) {
    this.setState({text: e.target.value});

    // Split and filter empty strings
    let count = e.target.value.split(" ").filter(function(el) {return el.length != 0}).length;
    this.setState({count: count});

    // Pass value upwards to changeHandler prop
    // this.props.changeHandler(e);
  }
  render() {
    return (
      <fieldset className="form-group">
        <label htmlFor={this.props.element.id}>{this.props.element.label} {this.props.element.required ? getLabelPill("required") : ""}</label>
        <HelpButton id={this.props.element.id} />
        <textarea value={this.props.fieldValue} id={this.props.element.id} className={"form-control" + ((this.state.count > this.state.limit) ? " is-invalid" : "")} 
          onChange={this.handleChange.bind(this)}></textarea>
        <p className="float-right mb-0 text-muted">{this.state.count} / {this.state.limit} words</p>
      </fieldset>
    )
  }
}

export default AbstractInput;
