import React from "react"

export const LabelPill = (props) => (
  <span className="badge badge-secondary">required</span>
)

export const SubmitButton = (props) => (
  <button className="btn btn-primary btn-lg float-right mb-5" type="submit">
    <i className="fa fa-fw fa-paper-plane" aria-hidden="true"></i> {!props.isEdit ? "Create" : "Submit"}
  </button>
)
