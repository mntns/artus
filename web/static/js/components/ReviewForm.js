import React from "react"
import Select from "react-select"
import channel from "../socket"

import FormContainer from "./FormContainer"

class ReviewForm extends React.Component {
  constructor() {
    super();
    this.state = {
      data: undefined,
      formData: [],
      caches: [],
      activeCache: undefined
    }
  }
  handleCacheSelect(data) {
    this.setState({ activeCache: data.value });
  }
  componentDidMount() {
    channel.push("options")
      .receive("ok", (data) => this.setState({data: data.options}));
    channel.push("caches")
      .receive("ok", (data) => this.setState({caches: data.caches}));
    channel.push("fields", {type: "r"})
      .receive("ok", (data) => this.setState({formData: data.fields}));
    console.log(this.state.formData);
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
            <div className="input-form-space"></div>
            <FormContainer systemType={window.systemType}
                           parentID={window.parentID} 
                           cache={this.state.activeCache} 
                           type={"r"} 
                           data={this.state.formData} />
          </div>
          }

        </div>
        )
      
  }
}

export default ReviewForm;
