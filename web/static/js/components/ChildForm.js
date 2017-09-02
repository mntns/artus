import React from "react"
import Select from "react-select"
import channel from "../socket"

import FormContainer from "./FormContainer"

class ChildForm extends React.Component {
  constructor() {
    super();
    this.state = {
      part: undefined,
      type: "a",
      data: undefined,
      formData: [],
      caches: [],
      activeCache: undefined
    }
  }
  handleTypeSelect() {
    channel.push("fields", {type: "a"})
      .receive("ok", (data) => this.setState({formData: data.fields}));
    this.setState({ type: "a" });
  }
  handleCacheSelect(data) {
    this.setState({ activeCache: data.value });
  }
  handlePartSelect(data) {
    this.setState({ part: data.value });
  }
  componentDidMount() {
    this.handleTypeSelect();
    channel.push("options")
      .receive("ok", (data) => this.setState({data: data.options}));
    channel.push("caches")
      .receive("ok", (data) => this.setState({caches: data.caches}));
    channel.push("saved_parent_entry", {id: window.parentID})
      .receive("ok", (data) => this.traverseEntry(data.entry));
  }
  replaceNils(i) {
    console.log(i);
    if (i == null) {
      return "";
    } else {
      return i;
    }
  }
  traverseEntry(entry) {
    console.log(entry);
    this.setState({entry: Object.keys(entry).reduce((newObj, key) => {
      newObj[key] = this.replaceNils(entry[key]);
      return newObj;
    }, {})});
  }
  render() { 
    if (!this.state.data) {
      return (
          <div className="center-block">
            <i className="fa fa-spinner fa-5x fa-spin"></i>
          </div>
      )
    }

    if (this.state.caches.length == 0) {
      return (
					<div className="alert alert-warning" role="alert">
					  <strong>No working cache! </strong> 
            You have no working cache associated with your account.
            Please <a href="/caches">click here</a> to create one.
					</div>
      )
    }

    return (
        <div>
          <fieldset className="form-group">
            <label htmlFor="cacheSelect">Working Cache</label>
            <Select className="cacheSelect" name="caches" value={this.state.activeCache} options={this.state.caches} onChange={this.handleCacheSelect.bind(this)} />
          </fieldset>

          {(this.state.activeCache == undefined) ? <p>Please select a working cache.</p> :
          <div>
          <fieldset className="form-group">
            <label htmlFor="partSelect">Section of Bibliography</label>
            <Select className="partSelect" name="parts" value={this.state.part} options={this.state.data.parts} onChange={this.handlePartSelect.bind(this)} />
          </fieldset>
        
          <fieldset className="form-group">
            <label htmlFor="typeSelect">Type</label>
            <Select className="typeSelect" name="types" value={this.state.type} options={this.state.data.types} readonly={true} disabled={true} />
          </fieldset>

          <div className="input-form-space"></div>
          
          {(this.state.formData && this.state.part) ? <FormContainer systemType={window.systemType}
                                                parentID={window.parentID}
                                                eEntry={this.state.entry}
                                                cache={this.state.activeCache} 
                                                part={this.state.part} 
          																			type={this.state.type} 
                                                data={this.state.formData} /> : <div className="alert alert-info">Please choose a part!</div>}
</div>
}
        </div>
        )
      
  }
}

export default ChildForm;
