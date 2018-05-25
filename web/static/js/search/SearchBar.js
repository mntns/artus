import React from 'react'
import channel from "../socket"
import Autocomplete from 'react-autocomplete'
import queryString from 'query-string'

class SearchBar extends React.Component {
  constructor() {
    super();
    this.state = {
      value: "",
      suggestions: []
    }
  }
  componentDidMount() {
    if (window.location.pathname.split('/')[1] == "search") {
      $('#searchWrapper').tooltip('dispose');
      let qs = queryString.parse(window.location.href.split("/").slice(-1)[0]);
      this.setState({value: qs.q});
    }
  }
  getOptions(input) {
    channel.push("autocomplete", {string: input})
      .receive("ok", (data) => {
        this.setState({suggestions: data.suggestions});
      });
  }
  handleFocus(value, event) {
    $('#searchWrapper').tooltip('dispose');
  }
  handleSubmit(event) {
    event.preventDefault();
    let qs = queryString.stringify({q: this.state.value});
    window.location.replace(window.location.origin + "/search/?" + qs);
  }
  render() {
    return (
      <form onSubmit={this.handleSubmit.bind(this)}>
        <div id="searchWrapper" data-toggle="tooltip" data-placement="bottom" 
          title="Searches by title, subtitle, author and editor">

          <Autocomplete
            autoHighlight={false}
            inputProps={{
              id: "searchBar", 
              onFocus: this.handleFocus.bind(this), 
              placeholder: "Search BIAS", 
              className: "form-control"}}
              wrapperStyle={{ position: 'relative' }}
              value={this.state.value}
              items={this.state.suggestions}
              getItemValue={(item) => item.value}
              onSelect={(value, item) => {
                this.setState({ value, suggestions: [ item ] })
              }}
              onChange={(event, value) => {
                this.setState({ value });
                this.getOptions(value);
              }}
              renderMenu={children => (
                <div className="card" id="searchCard">
                  {children}
                </div>
              )}
              renderItem={(item, isHighlighted) => (
                <div
                  className={"search-item ${isHighlighted ? 'search-item-active' : ''}"}
                  key={item.value}
                >{item.label}</div>
              )}
            />

        </div>
      </form>
    );
  }
}

export default SearchBar;
