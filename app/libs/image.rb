class Image
  def client
    @client ||= Aws::EC2::Client.new
  end

  def create_new_ami(machine, pod)
    image =
      client.create_image(
        {
          instance_id: machine.instance_id,
          name: "#{pod.app.name}-#{pod.name}-#{Time.now.to_i}",
          description: 'Automatically generated',
          no_reboot: false
        }
      )
    # block_device_mappings: [
    #   {
    #     virtual_name: "String",
    #     device_name: "String",
    #     ebs: {
    #       snapshot_id: "String",
    #       volume_size: 1,
    #       delete_on_termination: true,
    #       volume_type: "standard", # accepts standard, io1, gp2
    #       iops: 1,
    #       encrypted: true,
    #     },
    #     no_device: "String",
    #   },
    # ],

    begin
      client.wait_until(:image_available, image_ids: [image.image_id])
    rescue Aws::Waiters::Errors::FailureStateError => e
      Rails.logger.debug e.inspect
      raise e.response
    end
    return image.image_id
  end

  def delete_ami(ami)
    res = client.describe_images({ image_ids: [ami] })
    snapshots =
      res.images.map(&:block_device_mappings).flatten.map do |bdm|
        bdm.ebs.snapshot_id
      end
    client.deregister_image({ image_id: ami })
    snapshots.map { |snap| client.delete_snapshot({ snapshot_id: snap }) }
  end
end
