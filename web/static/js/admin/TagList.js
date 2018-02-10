import React from "react"
import channel from "../socket"

import R from "ramda"
import Fuse from "fuse.js"

class Tags extends React.Component {
  constructor(props) {
    super(props);

    this.fuse = new Fuse(props.items, props.fuseOptions);
  }
  componentDidMount() {
    channel.push("tags").receive("ok", (data) => this.setState({tags: data.tags}));
  }
  handleChange(event) {
    this.setState({search: event.target.value});

  }
  render() {
    return (
        <div className="mt-3">
        <ul className="list-group">
          {this.state.tags.map((tag, i) => 
            <li class="list-group-item">{tag.tag}</li>
            )}
        </ul>  
      </div>

    );
  }
}

export default TagList;
