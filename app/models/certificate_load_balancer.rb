class CertificateLoadBalancer < ActiveRecord::Base
  belongs_to :cert
  belongs_to :load_balancer
end
