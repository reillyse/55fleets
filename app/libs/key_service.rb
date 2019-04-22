require "aws-sdk-core"
class KeyService

  def create_new_key_pair key_pair_name

    key_pair = ec2.create_key_pair({
                                            key_name: key_pair_name
                                          })

  end
  def delete_key_pair key_pair_name

    ec2.delete_key_pair({
                                 key_name: key_pair_name
                               })

  end

  def ec2
    @ec2 ||= Aws::EC2::Client.new
  end

end
