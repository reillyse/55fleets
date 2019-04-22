class PodConfig < ActiveRecord::Base

  INSTANCE_SIZES = ["xsmall","tiny","small","medium","large","jumbo", "custom"]
  validates :name, :presence => true
  validates :number_of_members, :presence => true, inclusion: { in: 0..50 }
  validates :compose_command, :presence => true

  validates :instance_size, inclusion: { in: INSTANCE_SIZES,
                                         message: "%{value} is not a valid size" }

  before_save :instance_type_from_instance_size
  belongs_to :repo
  belongs_to :fleet_config


  before_validation :save_the_command

  def save_the_command
    if self.compose_filename.blank?

      self.compose_command = "docker-compose up -d"
      self.build_command = "docker-compose build"
    else
      self.compose_command = "docker-compose -f #{self.compose_filename} up -d"
      self.build_command = "docker-compose -f #{self.compose_filename} build"
    end
  end



  def self.size_to_instance size
    case size
    when "xsmall"
      "t3.micro"
    when "tiny"
      "t3.small"
    when "small"
      "t3.medium"
    when "medium"
      "m5.large"
    when "large"
      "m5.4xlarge"
    when "jumbo"
      "m5.10xlarge"
    end


  end

  def instance_type_from_instance_size
    self.instance_type = PodConfig.size_to_instance(self.instance_size) if self.instance_type.blank?
  end
end
