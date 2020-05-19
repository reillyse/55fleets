module BaseWorker

  def self.included(base)
    base.extend(NewMethods)
  end

  attr_accessor :object
  module NewMethods
    mattr_accessor :starting_state_name
    mattr_accessor :ending_state_name
    mattr_accessor :object_class_name
    
    
    def get_starting_state
      return self.starting_state_name
    end

    def get_ending_state
      return self.ending_state_name
    end
    
    def class_name name
      self.object_class_name = name
    end

    
    
    

    
    def starting_state(state_name=nil, &block)
      if block_given?
        self.starting_state_name = block
      else
        self.starting_state_name = state_name
      end
    end

    def ending_state(state_name=nil, &block)
      if block_given?
        self.ending_state_name = block
      else
        self.ending_state_name = state_name
      end
    end

    def check_the_starting_state object
      Rails.logger.debug "-------------------- states"
      Rails.logger.debug object.state.to_s.inspect
      Rails.logger.debug self.starting_state_name.to_s.inspect
      Rails.logger.debug "-------------------- state check over"
      
      return false unless object.state.to_s == self.starting_state_name.to_s
      return true
    end

    def check_the_ending_state object
      return false unless object.state.to_s == self.ending_state_name.to_s
      return true
    end
    

  end

  
  def perform object_id
    self.object = self.class.object_class_name.to_s.classify.constantize.find object_id
    
    Rails.logger.debug object
    return "Wrong Starting State #{self.class.starting_state_name} != #{object.state}" unless  self.class.check_the_starting_state(object)

    mutate object

    self.object = self.object.reload
    raise "Wrong Ending State #{self.class.ending_state_name} != #{object.state}" unless self.class.check_the_ending_state object
    
  end

  
  
  
  # def perform obj_id

  #   object = Object.find obj_id

  #   begin
  #     object.with_lock! do
  #       return false unless check_the_state(object)

  #     end
  #   rescue => e

  #     #remove other resources
  #     object.errors.add(e.message)
  #     object.state = state
  #     object.save!
  #   end
  


  # end
end
