import React from "react"

import {TextInput, TextBoxInput, AbbreviationInput} from "./Inputs"
import AbstractInput from "./AbstractInput"

const FormElement = (props) => {
  switch(props.element.type) {
    case "text":
      return <TextInput {...props} />
    case "textbox":
      return <TextBoxInput {...props} />
    case "year":
      // TODO: YearInput w/ bootstrap-datepicker
      return <TextInput {...props} />
    case "language":
      return <TextInput {...props} />
    case "badges":
      return <TagInput {...props} />
    case "abstract":
      return <AbstractInput {...props} />
    case "tags":
      // TODO: Implement tags
      return null;
    case "abbreviation":
      return <AbbreviationInput {...props} />
    default:
      return <p>{props.element.label}</p>
  }
}

export default FormElement;
