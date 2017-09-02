import React from "react"
import ReactDOM from "react-dom"
import HelpButton from "./help"

class TextBoxInput extends React.Component {
  constructor() {
    super();
  }
  componentDidMount() {
    let textboxDOMNode = ReactDOM.findDOMNode(this);
    let textarea = $(textboxDOMNode).find('textarea')[0];
    textarea.placeholder = textarea.placeholder.replace(/\\n/g, '\n');
  }

  render() {
    return (
        <fieldset className="form-group">
          <label htmlFor={this.props.element.id}>{this.props.element.label}</label>
          <HelpButton id={this.props.element.id} />
          <textarea value={this.props.fieldValue} onChange={this.props.changeHandler} className="form-control" id={this.props.element.id} placeholder={this.props.element.sample}></textarea>
        </fieldset>
        )
  }
}

export default TextBoxInput;
