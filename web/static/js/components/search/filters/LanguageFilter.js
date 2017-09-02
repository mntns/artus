import React from "react"
import Select from "react-select"
import channel from "../../../socket.js"

class LanguageFilter extends React.Component {
  constructor() {
    super();
    this.state = {
      languages: [],
      chosenLang: undefined
    }
  }
  onChange(value) {
    this.props.callback({lang: value});
    this.setState({chosenLang: value});
  }
  getLang(input, callback) {
    channel.push("languages")
    .receive("ok", (data) => { callback(null, {options: data.languages, complete: true})})
  }
  render() { 
    return (
            <div>
            <Select.Async value={this.state.chosenLang}
                          onChange={this.onChange.bind(this)}
                          loadOptions={this.getLang.bind(this)} />
            </div>
        );
  }
}

export default LanguageFilter;
