import React from "react"
import ReactDOM from "react-dom"
import Select from "react-select"
import channel from "../../socket"

import HelpButton from "./help"

function getLabelPill(text) {
  return <span className="label label-pill label-default">{text}</span>
}

class AbbreviationInput extends React.Component {
  constructor() {
    super();
    this.state = {
      data: [],
      value: undefined
    }
  }
  onChange(value) {
    this.setState({value: value});
    this.props.abbrHandler(value);
  } 
  getAbbr(input, callback) { 
    channel.push("abbreviations")
      .receive("ok", (data) => { callback(null, {options: data.abbr, complete: true}) })
  }
  renderOption(option) {
    return <div><b>{option.abbr}</b>: {option.title}</div>
  }
  render() {
    return (
        <fieldset className="form-group">
          <label htmlFor={this.props.element.id}>{this.props.element.label} {this.props.element.required ? getLabelPill("required") : ""}</label>
          <HelpButton id={this.props.element.id} />
					<Select.Async value={this.state.value} 
                        placeholder={this.props.element.sample}
                        valueKey="id" labelKey="abbr"
                        onChange={this.onChange.bind(this)}
                        loadOptions={this.getAbbr.bind(this)} 
                        optionRenderer={this.renderOption.bind(this)} />
        </fieldset>
        )
  }
}

export default AbbreviationInput;
