class SpotMachine < Machine
  belongs_to :spot_fleet_request

  scope :active, -> { where(:state => "active")}
  scope :submitted, -> { where(:state => "submitted")}

  
end
