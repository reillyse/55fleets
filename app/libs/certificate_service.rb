class CertificateService

  def initialize
    @client = Aws::IAM::Client.new
  end

  def upload_server_certificate name, cert_body, private_key, cert_chain

    resp = @client.upload_server_certificate({
                                               server_certificate_name: name,
                                               certificate_body: cert_body,
                                               private_key: private_key,
                                               certificate_chain: cert_chain
                                             })
    puts resp.inspect
    return resp.server_certificate_metadata.arn
  end
end
