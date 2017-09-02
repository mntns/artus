import React from "react"
import ReactDOM from "react-dom"
import Select from "react-select"
import channel from "../../socket"

import HelpButton from "./help"
import LabelPill from "./LabelPill"

class LanguageInput extends React.Component {
  constructor() {
    super();
    this.state = {
      data: [],
      value: undefined
    }
  }
  onChange(value) {
    this.setState({value: value});
    // Pass value to changeValue prop
    this.props.changeHandler({target: {id: this.props.element.id, value: value.value}});
  } 
  getTags(input, callback) { 
    channel.push("languages")
      .receive("ok", (data) => { callback(null, {options: data.languages, complete: true}) })
  }
  componentDidMount() {
    if (this.props.fieldValue) {
      this.setState({value: this.props.fieldValue});
    }
  }
  render() {
    return (
        <fieldset className="form-group">
          <label htmlFor={this.props.element.id}>{this.props.element.label} {this.props.element.required ? <LabelPill /> : ""}</label>
          <HelpButton id={this.props.element.id} />
					<Select.Async multi={false}
                        value={this.state.value} 
                        onChange={this.onChange.bind(this)}
                        loadOptions={this.getTags.bind(this)} />
        </fieldset>
        )
  }
}

export default LanguageInput;
