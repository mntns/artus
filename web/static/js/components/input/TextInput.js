import React from "react"
import HelpButton from "./help"
import LabelPill from "./LabelPill"

class TextInput extends React.Component {
  constructor() {
    super();
  }
  render() {
    // element: id, label, required
    return (
        <fieldset className="form-group">
          <label htmlFor={this.props.element.id}>{this.props.element.label} {this.props.element.required ? <LabelPill /> : null} </label>
          <HelpButton id={this.props.element.id} />
          <input value={this.props.fieldValue} 
                 onChange={this.props.changeHandler} 
                 type="text" 
                 className="form-control" 
                 id={this.props.element.id} 
                 placeholder={this.props.element.sample} 
                 required={this.props.element.required} />
        </fieldset>
        )
  }
}

export default TextInput;
