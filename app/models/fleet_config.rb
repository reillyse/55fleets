class FleetConfig < ActiveRecord::Base

  belongs_to :app
  has_many :pod_configs
  has_many :fleets
  accepts_nested_attributes_for :pod_configs
  
end
