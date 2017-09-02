import React from "react"
import Select from "react-select"
import Operator from "./Operator"
import channel from "../../socket"

import TitleFilter from "./filters/TitleFilter.js"
import LanguageFilter from "./filters/LanguageFilter.js"
import YearFilter from "./filters/YearFilter.js"
import EditorFilter from "./filters/EditorFilter.js"
import AuthorFilter from "./filters/AuthorFilter.js"

class FilterElement extends React.Component {
  constructor() {
    super();
    this.state = {
      operator: "and",
      params: undefined
    }
  }
  pushParams(p) {
    this.props.propagateParams(this.props.elementID, this.state.operator, p);
    this.setState({params: p});
  }
  updateOperator(o) {
    this.props.propagateParams(this.props.elementID, o, this.state.params);
    this.setState({operator: o});
  }
  render() { 
    switch(this.props.type) {
      case "title":
        return (
          <div>
            <TitleFilter callback={this.pushParams.bind(this)} />
          </div>
        )
        break;
      case "lang":
        return (
            <div>
              <LanguageFilter callback={this.pushParams.bind(this)} />
            </div>
            )
        break;
      case "year":
        return (
            <div>
              <YearFilter callback={this.pushParams.bind(this)} />
            </div>
            )
          break;
      case "author":
        return (
            <div>
              <AuthorFilter callback={this.pushParams.bind(this)} />
            </div>
            );
        break;
      case "editor":
        return (
            <div>
              <EditorFilter callback={this.pushParams.bind(this)} />
            </div>
            );
        break;
      default:
        return (<p>invalid type</p>);
        break;
    }
  }
}

export default FilterElement;
