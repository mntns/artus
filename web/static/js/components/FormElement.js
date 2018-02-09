import React from "react"

import TextInput from "./input/TextInput"
import TextBoxInput from "./input/TextBoxInput"
import LanguageInput from "./input/LanguageInput"
import TagInput from "./input/TagInput"
import AbstractInput from "./input/AbstractInput"

class FormElement extends React.Component {
  constructor() {
    super();
  }
  render() {
    switch(this.props.element.type) {
      case "text":
        return <TextInput element={this.props.element} changeHandler={this.props.changeHandler} />
      case "textbox":
        return <TextBoxInput element={this.props.element} changeHandler={this.props.changeHandler} />
      case "year":
        // TODO: YearInput w/ bootstrap-datepicker
        return <TextInput element={this.props.element} changeHandler={this.props.changeHandler} />
      case "language":
        return <TextInput element={this.props.element} />
        //return <LanguageInput element={this.props.element} />
      case "badges":
        return <TagInput element={this.props.element} changeHandler={this.props.changeHandler} />
      case "abstract":
        // Set limit according to type
        if (this.props.type == "b") {
          return <AbstractInput element={this.props.element} limit={100} changeHandler={this.props.changeHandler} />
        } else {
          return <AbstractInput element={this.props.element} limit={50} changeHandler={this.props.changeHandler} />
        }
      default:
        return <p>{this.props.element.label}</p>
    }
  }
}

export default FormElement;
