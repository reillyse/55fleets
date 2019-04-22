var Machine = React.createClass({
    propTypes: {
        ipAddress: React.PropTypes.string,
        initialState: React.PropTypes.object

    },

    fetchState: function () {

        var _this = this;
        $.ajax('/machine/' + _this.props.initialState.id, {
            method: 'GET',
            dataType: 'json'
        }).done(function (data) {

            _this.setState(data);

        })
    },

    toggleMachineLogs: function () {
        this.state.showMachineLogs = !(this.state.showMachineLogs);

        var mlt = this.refs.machinelogs;


        if (this.state.showMachineLogs) {
            mlt.startFetchingLogs();
            mlt.fetchLogs();
        } else {
            mlt.stopFetchingLogs();
        }
        this.forceUpdate();
        },

    toggleBuildLogs: function () {
        this.state.showBuildLogs = !(this.state.showBuildLogs);

        var blt = this.refs.buildlogs;

        if (this.state.showBuildLogs) {

            blt.startFetchingLogs();
            blt.fetchLogs();
        } else {

            blt.stopFetchingLogs();
        }
        this.forceUpdate();

    },

    componentWillMount: function () {

        this.setState(this.props.initialState);
        //setInterval(this.fetchState, 5000);
        this.setState({showMachineLogs: false});
        this.setState({showBuildLogs: false});

    },
    componentWillReceiveProps: function (nextProps) {
        console.log("Receiving props");
        console.log(nextProps);
        this.setState(nextProps.initialState);
    },

    render: function() {

        return (
            <div className="machine-wrapper">
    	        <div className="machine-view">
                    <div className="heading">
                        <div className="pod-name">
                            {this.state.pod.name}
                        </div>
                        <div className="status-indicator">
                            <div className={this.state.state + ' indicator'}>
                                {this.state.state}
                                <div className={'circle ' + this.state.state + '-circle'}>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className="machine-details">
                        <table>
                            <tbody>
                            <tr>
                                <td> Ip Address</td>
                                <td> {this.state.ip_address} </td>
                            </tr>
                            <tr>
	                        <td > Subnet</td>
                                <td> {this.state.subnet ? this.state.subnet.subnet_id : ""}</td>
                            </tr>
                            <tr>
		                <td > Availability Zone </td>
                                <td> {this.state.subnet ? this.state.subnet.availability_zone : ""}</td>
                            </tr>
                            <tr>
	                        <td > Type </td>
                                <td> {this.state.instance_type}</td>
                            </tr>
                            <tr>

                                <td >  Deployed</td>
                                <td> { this.state.deployed_at ? (new Date(this.state.deployed_at)).toString() : ""}</td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <div className={"logs-button blue-button " + (this.state.showMachineLogs ? "" : "inverted-button")} onClick={this.toggleMachineLogs}>
                        VIEW LOGS
                    </div>
                    <div className={"logs-button blue-button " + (this.state.showBuildLogs ? "" :"inverted-button")} onClick={this.toggleBuildLogs}>
                        VIEW BUILD LOGS
                    </div>

                </div>
                <div id="machine-logs" className={(this.state.showMachineLogs ? "" : "hidden "  ) + "log-terminal "} >


                    <LogTerminal machineID={this.state.id} appID="tanker" ref="machinelogs"> </LogTerminal>
                </div>
                <div id="build-logs" className={"log-terminal " + ( this.state.showBuildLogs ? "" : "hidden") } >
                    <LogTerminal machineID={this.state.pod.builder_id} appID="tanker" ref="buildlogs">  </LogTerminal>

                </div>
            </div>

        );
    }
});
