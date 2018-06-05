import React from "react"

class FilterContainer extends React.Component {
  constructor() {
    super();
    this.state = {
    };
  }
  render() {
    return (
    <div className="card">
        <div className="card-header nav">
          <div className="btn-group ml-auto" role="group" aria-label="Basic example">
            <button type="button" className="btn btn-danger">Delete</button>
          </div>
        </div>
      <div className="card-body">
        <p> test</p>
      </div>
    </div>
    )
  }
}

export default FilterContainer;
