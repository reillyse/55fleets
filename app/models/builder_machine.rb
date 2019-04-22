class BuilderMachine < Machine

  def recycle_as_new

    new_me = self.dup
    self.with_lock('FOR UPDATE NOWAIT') do
      self.recycle!
      self.save!
    end
    new_me.clear_old_docker_images
    new_me.clean_deploy_dir
    new_me.state = "running"
    new_me.busy = nil
    new_me.save!


  end

end
