import React from "react"

class SubmitButton extends React.Component {
  constructor() {
    super();
  }
  render() {
    return (
      <button className="btn btn-primary btn-lg pull-xs-right" type="submit">
        <i className="fa fa-paper-plane" aria-hidden="true"></i> Create
      </button>
    );
  }
}

export default SubmitButton;
