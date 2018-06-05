import React from 'react'
import FilterGroup from "./FilterGroup"

class AdvancedSearch extends React.Component {
  constructor() {
    super();
    this.state = {
      data: {}
    }
  }
  render() {
    return (
      <div>
        <FilterGroup />

        <button>Submit</button>
      </div>
    )
  }
}

export default AdvancedSearch;
