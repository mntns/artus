import React from "react"
import HelpButton from "./help"

function getLabelPill(text) {
  return <span className="label label-pill label-default">{text}</span>
}

class AbstractInput extends React.Component {
  constructor() {
    super();
    this.state = {
      text: "",
      count: 0
    }
  }
  handleChange(e) {
    console.log(e);
    this.setState({text: e.target.value});

    // Split and filter empty strings
    let count = e.target.value.split(" ").filter(function(el) {return el.length != 0}).length;
    this.setState({count: count});
    
    // Pass value upwards to changeHandler prop
    this.props.changeHandler(e);
  }
  render() {
    let limit = this.props.limit;
    return (
        <fieldset className={"form-group" + ((this.state.count > limit) ? " has-danger" : "")}>
          <label htmlFor={this.props.element.id}>{this.props.element.label} {this.props.element.required ? getLabelPill("required") : ""}</label>
          <HelpButton id={this.props.element.id} />
          <textarea value={this.props.fieldValue} id={this.props.element.id} className="form-control" onChange={this.handleChange.bind(this)}></textarea>
          <p className="pull-xs-right">{this.state.count} / {limit} words</p>
        </fieldset>
        )
  }
}

export default AbstractInput;
