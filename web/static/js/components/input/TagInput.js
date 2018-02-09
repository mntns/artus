import React from "react"
import ReactDOM from "react-dom"
import { AsyncCreatable } from "react-select"
import channel from "../../socket"

import LabelPill from "./LabelPill"
import HelpButton from "./help"

class TagInput extends React.Component {
  constructor() {
    super();
    this.state = {
      data: [],
      value: []
    }
  }
  onChange(value) {
    this.setState({value: value});
    // Pass value to changeValue prop
    this.props.changeHandler({target: {id: this.props.element.id, value: value}});
  } 
  getTags(input, callback) { 
    channel.push("badges", {type: this.props.element.id})
      .receive("ok", (data) => { callback(null, {options: data.badges, complete: true}) })
  }
  constructWeirdElement(rendered) {
    return {__html: rendered};
  }
  renderOption(option) {
    return <div dangerouslySetInnerHTML={this.constructWeirdElement(option.rendered)} />
  }
  componentDidMount() {
    if (this.props.fieldValue) {
      this.setState({value: this.props.fieldValue});
    }
  }
  createPromptText(label) {
    return "Create badge \"" + label + "\"";
  }
  render() {
    return (
        <fieldset className="form-group">
          <label htmlFor={this.props.element.id}>{this.props.element.label} {this.props.element.required ? <LabelPill /> : ""}</label>
          <HelpButton id={this.props.element.id} />
					<AsyncCreatable multi={true}
                          value={this.state.value} 
                          onChange={this.onChange.bind(this)}
                          valueKey="id" labelKey="rendered"
                          loadOptions={this.getTags.bind(this)}
                          optionRenderer={this.renderOption.bind(this)} 
                          valueRenderer={this.renderOption.bind(this)}
                          promptTextCreator={this.createPromptText.bind(this)} />
        </fieldset>
        )
  }
}

export default TagInput;
