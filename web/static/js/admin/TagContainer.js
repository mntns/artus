import React from "react"
import channel from "../socket"

import R from "ramda"
import Fuse from "fuse.js"

const FUSE_OPTIONS = {
	shouldSort: true,
	threshold: 0.4,
	location: 0,
	distance: 100,
	maxPatternLength: 32,
	minMatchCharLength: 1,
	keys: ["raw"]
};

class TagContainer extends React.Component {
	constructor() {
		super();
		this.state = {
			search: "",
			tags: []
		}

		this.handleChange = this.handleChange.bind(this);
		this.fuse = new Fuse(this.state.tags, FUSE_OPTIONS);
	}
	componentDidMount() {
    // Force scrollbar to appear
    $("body").css("overflow-y", "scroll");

		channel.push("tags").receive("ok", (data) => {
			this.setState({tags: data.tags});
			this.fuse = new Fuse(this.state.tags, FUSE_OPTIONS);
		});
	}
	handleChange(event) {
		this.setState({search: event.target.value});

	}
  constructInnerHTML(string) {
    return {__html: string};
  }
	render() {
    let tag_list = null;    
    if (this.state.search == "") {
      tag_list = this.state.tags;
    } else {
      tag_list = this.fuse.search(this.state.search);
    }

		return (
			<div>
				<div className="input-group">
					<input type="text"
						className="form-control" 
						placeholder="Search or enter new tag" 
						aria-label="Search or enter new tag" 
						aria-describedby="basic-addon2"
						value={this.state.search}
						onChange={this.handleChange} />
					<div className="input-group-append">
						<button className="btn btn-primary disabled" type="button">
							<i className="fa fa-fw fa-plus" aria-hidden="true"></i> Add as tag
						</button>
					</div>
				</div>
        
        <ul className="list-group mt-3">
          {tag_list.map((t, i) =>
            <li className="list-group-item" dangerouslySetInnerHTML={this.constructInnerHTML(t.rendered)} key={i} />
          )}
        </ul>
			</div>
		);
	}
}

export default TagContainer;
