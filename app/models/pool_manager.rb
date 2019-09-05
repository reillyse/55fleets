class PoolManager

  #provisions machines based on capacity and spot fleet

  # create a spot fleet

  # checks the spot fleet instances


  # spawn fleet

  def self.create_fleet instance_count,pod,instance_types=nil

    sfr = SpotFleetRequest.create!(:state => "creating" , :instance_count => instance_count,pod: pod, instance_types: instance_types)
    pod.spot_fleet_request = sfr
 
     pod.save!

    sfr.initialize_fleet
    sfr
  end

  # pool fleet for changes
  def check_fleet

  end


  def scale_fleet_up
  end

  def scale_fleet_down
  end
  # update local representation of fleet




end
