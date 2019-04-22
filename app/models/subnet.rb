class Subnet < ActiveRecord::Base
  belongs_to :vpc
  has_many :machines
end
