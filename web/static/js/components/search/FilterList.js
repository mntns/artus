import React from "react"

class FilterList extends React.Component {
  constructor() {
    super();
    this.state = {
      attributs: ["language", "author"]
    }
  }
  render() { 
    return (
        <h1>FilterList</h1>
        )
  }
}

export default FilterList;
