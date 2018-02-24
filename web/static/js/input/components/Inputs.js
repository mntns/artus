import React from "react"
import ReactDOM from "react-dom"
import Select from "react-select"
import {LabelPill} from "./Helpers"
import HelpButton from "./HelpButton"
import {getAutoComplete} from "../actions"

export const TextBoxInput = (props) => (
  <fieldset className="form-group">
    <label htmlFor={props.element.id}>{props.element.label} {props.element.required ? <LabelPill /> : null} </label>
    <HelpButton id={props.element.id} />
    <textarea {...props.input} className="form-control" id={props.element.id} placeholder={props.element.sample}></textarea>
  </fieldset>
)

// TODO: https://github.com/bvaughn/react-virtualized-select/
export const SelectInput = (props) => (
  <fieldset className="form-group">
    <label htmlFor={props.element.id}>{props.element.label}</label>
    <Select 
      {...props.input} 
      required={props.element.required}
      disabled={props.element.disabled}
      value={props.input.value || ''} 
      onBlur={() => props.input.onBlur(props.input.value)} 
      options={props.options} 
      labelKey={props.labelKey}
      optionRenderer={props.optionRenderer} />
  </fieldset>
)

export const TextInput = (props) => (
  <fieldset className="form-group">
    <label htmlFor={props.element.id}>{props.element.label} {props.element.required ? <LabelPill /> : null} </label>
    <HelpButton id={props.element.id} />
    <input 
      {...props.input}
      type="text" 
      className="form-control" 
      id={props.element.id} 
      placeholder={props.element.sample} 
      required={props.element.required} />
  </fieldset>
)

const renderAbbreviationOption = (option) => (
  <div><b>{option.abbr}</b>: {option.title}</div>
)

export const AbbreviationInput = (props) => (
  <SelectInput
    {...props}
    optionRenderer={renderAbbreviationOption} 
    labelKey={"abbr"} />
)
