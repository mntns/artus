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

    let handleChange = this.handleChange.bind(this);
  }
  componentWillMount() {
    if (this.props.formType.value == "b") {
      this.setState({limit: 100})
    }
  }
  componentWillReceiveProps(nprops) {
    if (nprops.formType.value == "b") {
      this.setState({limit: 100})
    }
  }
  handleChange(e) {
    // Split and filter empty strings
    let count = e.target.value.split(" ").filter(function(el) {return el.length != 0}).length;
    this.setState({count: count});
  }
  render() {
    return (
      <fieldset className="form-group">
        <label htmlFor={this.props.element.id}>{this.props.element.label} {this.props.element.required ? <LabelPill /> : ""}</label>
        <HelpButton id={this.props.element.id} />
        <textarea {...this.props.input} id={this.props.element.id} className={"form-control" + ((this.state.count > this.state.limit) ? " is-invalid" : "")} 
          onChange={value => {this.props.input.onChange(value); this.handleChange(value);}}></textarea>
        <p className="float-right mb-0 text-muted">{this.state.count} / {this.state.limit} words</p>
      </fieldset>
    )
  }
}

export default AbstractInput;
