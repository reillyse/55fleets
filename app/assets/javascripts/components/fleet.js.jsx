var Fleet = React.createClass({
    propTypes: {
        initialState: React.PropTypes.object
    },

    revertToFleet: function () {
        var revert_url = "fleet_configs/" + this.state.id + "/launch_from_fleet";
        var _this = this;
        $.post(revert_url).done(function(event) {
            console.log("created new fleet");
            _this.toggleDisplay();
        });
    },

    fetchState: function() {


        $.ajax('/fleet/' + this.props.initialState.id, {
            method: 'GET',
            dataType: 'json',
            context: this,
        }).done(function (data) {
            this.setState(data);
        })
    },


    componentWillMount: function() {
        this.setState(this.props.initialState);
    },

    componentWillReceiveProps: function (nextProps) {
        console.log("Receiving props");
        console.log(nextProps);
        this.setState(nextProps.initialState);
    },

    toggleDisplay: function() {

        this.setState({drilledDown: !this.state.drilledDown});

    },

    renderTable: function() {
        return (
            <tr>
                <td>
                    <button className="view-fleet-button standard-button inverted-button" onClick={this.toggleDisplay}>
                        VIEW
                    </button>
                </td>

                <td className="fleet-created-at">
                    {moment(this.state.created_at).format('MMMM Do YYYY, h:mm:ss a')}
                </td>
                <td>
                    {this.state.pods.length}
                </td>
                <td>
                    {this.state.machines.length}
                </td>
                <td>
                    {this.state.running_count}
                </td>
            </tr>

        );
    },
    renderDrillDown: function () {
        return (
            <tr>
            <td>
    	    <div className="fleet">
                <div className="show-hide-fleet float-right">
                    <button className="view-fleet-button standard-button inverted-button" data-fleet-id="this.props.id" onClick={this.toggleDisplay}>
            HIDE

            </button>
            </div>

            <button className="view-fleet-button standard-button inverted-button revert-fleet-button" onClick={this.revertToFleet}>
            REVERT
            </button>



                <div> Rolling Deploy Completed At: {this.state.rolling_deploy_completed_at ? (new Date(this.state.rolling_deploy_completed_at)).toString() : "" } </div>
                {this.state.pods.map(function (pod,i) {
                     return(
                         <div className="fleet-scale" key={pod.id}>
                             <div className="scale-pod-name">
                                 {pod.name}
                             </div>
                             <div className="outer-scale-wrapper">
                                 <div className="scale-wrapper">
                                     <ScaleButton  appName={this.props.initialState.appName} fleetID={this.props.initialState.id} podID={pod.id} numberOfMachines={pod.permanent_minimum} machineType="on_demand"  />
                                 </div>
                                 <div className="scale-wrapper">
                                     <ScaleButton  appName={this.props.initialState.appName} fleetID={this.props.initialState.id} podID={pod.id} numberOfMachines={pod.spot_amount} machineType="spot" />
                                 </div>
                             </div>
                             { $.grep(this.state.machines, function(e){ return e.pod_id == pod.id }).length == 0 ?
                               [
                                   <span>
                                       BUILD LOGS
                                   </span>,
                             <div className="build-wrapper log-terminal">

                                         <LogTerminal machineID={pod.builder_id} fetchingLogs={true} />
                             </div>
                                   ]
                              :""
                             }
                         </div>)
                 }.bind(this))}
                         {this.state.machines.map(function (machine,i) {

                              return (<div key={machine.id}>

                             <Machine initialState={machine} />
                              </div>)
                          })

                         }

	    </div>
            </td>
            </tr>
        );},

    render: function() {
        return this.state.drilledDown ? this.renderDrillDown() : this.renderTable() ;
    }
});
