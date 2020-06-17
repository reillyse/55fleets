class Cert < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  has_many :certificate_load_balancers
  has_many :load_balancers, :through => :certificate_load_balancers

  attr_encrypted :certificate, :key => ENV["CERT_KEY_SECRET"], :mode => :per_attribute_iv_and_salt,algorithm: 'aes-256-cbc', insecure_mode: true
  attr_encrypted :private_key, :key => ENV["CERT_KEY_SECRET"], :mode => :per_attribute_iv_and_salt,algorithm: 'aes-256-cbc', insecure_mode: true

  before_create :save_cert_to_aws

  def save_cert_to_aws
    self.aws_ssl_cert_id = CertificateService.new.upload_server_certificate "#{self.app.name}-#{self.name}", self.certificate, self.private_key, self.cert_chain
  end
end
