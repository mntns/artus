import React from "react"
import channel from "../socket"
import Fuse from "fuse.js"

const FUSE_OPTIONS = {
	shouldSort: true,
	threshold: 0.4,
	location: 0,
	distance: 100,
	maxPatternLength: 32,
	minMatchCharLength: 1,
	keys: ["abbr", "title"]
};

class AbbreviationContainer extends React.Component {
	constructor() {
		super();
		this.state = {
			search: "",
			abbreviations: []
		}

		this.handleChange = this.handleChange.bind(this);
		this.fuse = new Fuse(this.state.abbreviations, FUSE_OPTIONS);
	}
	componentDidMount() {
    // Force scrollbar to appear
    $("body").css("overflow-y", "scroll");

		channel.push("abbreviations").receive("ok", (data) => {
			this.setState({abbreviations: data.abbreviations});
			this.fuse = new Fuse(data.abbreviations, FUSE_OPTIONS);
		});
	}
	handleChange(event) {
		this.setState({search: event.target.value});

	}
  constructInnerHTML(string) {
    return {__html: string};
  }
	render() {
    let abbreviation_list = null;    
    if (this.state.search == "") {
      abbreviation_list = this.state.abbreviations;
    } else {
      abbreviation_list = this.fuse.search(this.state.search);
    }

		return (
			<div>
				<div className="input-group">
					<input type="text"
						className="form-control" 
						placeholder="Search for abbreviation" 
						aria-label="Search for abbreviation" 
						aria-describedby="basic-addon2"
						value={this.state.search}
						onChange={this.handleChange} />
					<div className="input-group-append">
            <a className="btn btn-primary" href="/admin/abbreviations/new">
							<i className="fa fa-fw fa-plus" aria-hidden="true"></i> Add new abbreviation
            </a>
					</div>
				</div>
        
        <div className="list-group mt-3">
          {abbreviation_list.map((a, i) =>
            <a className="list-group-item" key={i} href={"/admin/abbreviations/" + a.id}>
              <b>{a.abbr}</b> {a.title}
            </a>
          )}
        </div>
			</div>
		);
	}
}

export default AbbreviationContainer;
