class CertificateService
  def initialize
    @client = Aws::IAM::Client.new
  end

  def upload_server_certificate(name, cert_body, private_key, cert_chain)
    resp =
      @client.upload_server_certificate(
        {
          server_certificate_name: name,
          certificate_body: cert_body,
          private_key: private_key,
          certificate_chain: cert_chain
        }
      )
    Rails.logger.debug resp.inspect
    return resp.server_certificate_metadata.arn
  end

  # def create_certificate
  #   resp = client.request_certificate({
  #                                       domain_name: "DomainNameString", # required
  #                                       validation_method: "EMAIL", # accepts EMAIL, DNS
  #                                       subject_alternative_names: ["DomainNameString"],
  #                                       idempotency_token: "IdempotencyToken",
  #                                       domain_validation_options: [
  #                                         {
  #                                           domain_name: "DomainNameString", # required
  #                                           validation_domain: "DomainNameString", # required
  #                                         },
  #                                       ],
  #                                       options: {
  #                                         certificate_transparency_logging_preference: "ENABLED", # accepts ENABLED, DISABLED
  #                                       },
  #                                       certificate_authority_arn: "Arn",
  #                                     })
  # end
end
