class Imager
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform(pod_id)
    pod = Pod.find pod_id
    machine = pod.builder
    begin
      pod.with_lock('FOR UPDATE NOWAIT') do
        raise 'Pod is not built' if pod.created?

        if pod.ami.blank?
          machine.log('Creating Image', :imager)

          pod.imaging_started!
        else
          return 'POD already built'
        end
      end

      ami = Image.new.create_new_ami machine, pod

      pod.ami = ami
      raise 'We need an ami' if ami.blank?
      pod.save!
      machine.log('Image Complete', :imager)

      pod.imaged!
    rescue => e
      pod.back_to_built! if pod.imaging? || pod.image_available?
      raise e
    end

    PodInit.perform_later pod.id
    Recycler.perform_async(machine.id)
  end
end
