import React from "react"
import update from "react-addons-update";
import channel from "../socket"

import SubmitButton from "./SubmitButton"
import TextInput from "./input/TextInput"
import TextBoxInput from "./input/TextBoxInput"
import LanguageInput from "./input/LanguageInput"
import TagInput from "./input/TagInput"
import AbstractInput from "./input/AbstractInput"
import AbbreviationInput from "./input/AbbreviationInput"

class FormContainer extends React.Component {
  constructor() {
    super();
    this.state = {
      data: undefined,
      content: [],
      form: {},
      uuid: undefined,
      initialized: false
    }
  }
  handleChange(e) {
    let updatedState = update(this.state, {form: {[e.target.id]: {$set: e.target.value}}});
    this.setState(updatedState);
  }
  submitForm(e) {
    e.preventDefault();
    channel.push("submit", {data: this.state.form})
      .receive("ok", (data) => (window.location.href = "/review/" + data.id))
  }
  onAbbreviation(value) {
    channel.push("abbreviations", {id: value.id})
      .receive("ok", (data) => this.setState(update(this.state, {
        form: {
          $merge: {
            ser_code: data.abbr,
            ser_title: data.title, 
            biblio_issn: data.issn,
            publ_pub_house: data.publisher,
            publ_pub_place: data.place
          }
        }
      })))
  }
  componentDidMount() {
    this.setState({form: {type: this.props.type}});
    let updatedState = update(this.state, {form: {$merge: {systemType: this.props.systemType, parentID: this.props.parentID, type: this.props.type, cache: this.props.cache, part: this.props.part}}});
    this.setState(updatedState);
  }
  componentWillReceiveProps() {
    if (!this.state.initialized) {
      this.props.data.map((x,i) => {this.state.form[x.id] = ""});
      this.setState({initialized: true});
    }
    let updatedState = update(this.state, {form: {$merge: {type: this.props.type, cache: this.props.cache, part: this.props.part}}});
    if (this.props.eEntry) {
      let evenMoreUpdatedState = update(updatedState, {form: {$merge: this.props.eEntry}});
      this.setState(evenMoreUpdatedState);
    } else {
      this.setState(updatedState);
    }
  }
  render() {
    // Check for type
    if (!this.props.data) {
      return <p>No type chosen.</p>
    }

    if (this.state.form) {
      return (
        <form onSubmit={this.submitForm.bind(this)}>
        {this.props.data.map((x, i) => {
          switch(x.type) {
              // TODO: YearInput w/ bootstrap-datepicker
            case "text":
              return <TextInput key={i} element={x} fieldValue={this.state.form[x.id]} changeHandler={this.handleChange.bind(this)} />
                break;
            case "textbox":
              return <TextBoxInput key={i} element={x} fieldValue={this.state.form[x.id]} changeHandler={this.handleChange.bind(this)} />
                break;
            case "language":
              return <LanguageInput key={i} element={x} fieldValue={this.state.form[x.id]} changeHandler={this.handleChange.bind(this)} />
                break;
            case "tags":
              if (this.props.eEntry) {
                return <div key={i} className="alert alert-warning">Currently tags cannot be edited.</div>;
                break;
              } else {
                return <TagInput key={i} element={x} fieldValue={this.state.form[x.id]} changeHandler={this.handleChange.bind(this)} />
                  break;
              }
            case "abbreviation":
              return <AbbreviationInput key={i} element={x} fieldValue={this.state.form[x.id]} abbrHandler={this.onAbbreviation.bind(this)} />
                break;
            case "abstract":
              // Set limit according to type
              if (this.props.type == "b") {
                return <AbstractInput key={i} element={x} fieldValue={this.state.form[x.id]} limit={100} changeHandler={this.handleChange.bind(this)} />
              } else {
                return <AbstractInput key={i} element={x} fieldValue={this.state.form[x.id]} limit={50} changeHandler={this.handleChange.bind(this)} />
              }
              break;
            default:
              return <p key={i}>{x.label}</p>
                break;
          }
        }

        )}


        <SubmitButton />
        </form>
      )
    }

  }
}

export default FormContainer;
