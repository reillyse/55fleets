var ScaleButton = React.createClass({
    propTypes: {
        //initialState: React.PropTypes.object,
        fleetID: React.PropTypes.number.isRequired,
        podID: React.PropTypes.number.isRequired,
        appName: React.PropTypes.string.isRequired,
        numberOfMachines: React.PropTypes.number.isRequired,
        machineType: React.PropTypes.string.isRequired,
        showScaleButton: React.PropTypes.bool
    },
    componentWillMount: function() {
        this.setState(this.props);
        var url = "/apps/" + this.props.appName + "/pods/" + this.props.podID + "/scale";
        this.setState({scaleUrl: url});
        //this.setState({show_scale_button: false});
    },
    scale: function (event) {
        console.log("Scaling");
        event.preventDefault();
        target = event.target;
        var new_amount = $(target).parent().find("#new_amount").val();
        this.scaleFleetTo(new_amount);

        return false;
    },
    scaleFleetTo: function(new_amount) {
        this.setState({numberOfMachines: new_amount});
        console.log("url is " + this.state.scaleUrl);
        $.ajax({
            url: this.state.scaleUrl,
            method: 'POST',
            dataType: 'json',
            data: {
                pod_scale: {
                    machine_type: this.props.machineType,
                    new_amount: new_amount
                }
            },
            context: this,
            error: function (data,error,excp) {
                console.log("We have failed");
                console.log(data);
                console.log(error);
                console.log(excp);
                console.log("^^^^^^^^^^^");
            },
            complete: function (data) {
                console.log("Scaled " + this.props.podID + " to " +  this.state.numberOfMachines );
            }})

    },

    toggleButton (event) {
        if ($(event.target).hasClass("scale-form-input")) {

            return false;

        }
        console.log(this);
        if (this.state.showScaleButton == true) {
            this.setState({showScaleButton: false});

        } else {
            this.setState({showScaleButton: true});

        }


    },


    render: function () {

        return (
            <div>
                <div className="pod-scale-comp" id={this.props.podID} onClick={this.toggleButton}>
                    <div className={this.state.showScaleButton ? 'fleet-instance-count hidden can-edit' : 'fleet-instance-count show can-edit'} >
                        <span className="count">
                            {this.state.numberOfMachines}
                        </span>
                        <span className="describe">
                            <div className="top">
                                {this.props.machineType == "on_demand" ? "ON DEMAND" : "SPOT"}
                            </div>
                            <div className="bottom">
                                INSTANCES
                            </div>
                        </span>
                        <span className="pencil-edit">
                            <i className="fa fa-pencil">
                            </i>
                        </span>
                    </div>


                    <div className={this.state.showScaleButton ? 'scale-instances show' : 'scale-instances hidden' } onClick={this.toggleButton} >
                        <div className='label'>
                            {this.props.machineType == "on_demand" ? "ON DEMAND" : "SPOT"} INSTANCES
                        </div>
                        <input type="text" name="new_amount" id="new_amount" defaultValue={this.state.numberOfMachines} className="scale-form-input" maxLength="3" width="20px" onClick=""/>
                        <input type="submit"  value="SCALE" className="blue-button scale-button" submit={function(e) {e.preventDefault();}} onClick={this.scale}/>
                    </div>


                </div>
            </div>
        )

    }

});
