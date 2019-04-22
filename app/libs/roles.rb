class Roles



  def client
    @client ||= Aws::IAM::Client.new
  end


  def iam
    @iam ||= Aws::IAM::Resource.new(client: client)
  end

  def create_spot_fleet_role


    role = iam.create_role({
                             role_name: spot_fleet_role_name,
                             assume_role_policy_document: trust_policy_doc.to_json
                           })

    policy = create_policy
    client.attach_role_policy role_name: spot_fleet_role_name,policy_arn: policy.arn
    client.attach_role_policy policy_arn: "arn:aws:iam::aws:policy/AdministratorAccess", role_name: role.role_name
    return role
  end

  def create_policy
    policy_name = "fleet_policy5"

    return client.create_policy({policy_document: admin_policy.to_json, policy_name: policy_name}).policy
  end

  def admin_policy
    {
      "Version": "2012-10-17",
     "Statement": [
                    {
                      "Effect": "Allow",
                     "Action": [
                                 "ec2:*"
                               ],
                     "Resource": "*"
                    },
                    {
                      "Effect": "Allow",
                     "Action": [
                                 "iam:ListRoles",
                                 "iam:PassRole",
                                 "iam:ListInstanceProfiles"
                               ],
                     "Resource": "*"
                    }
                  ]
    }


  end


  def trust_policy_doc
    {
      "Version": "2012-10-17",
     "Statement": [
                    {
                      "Effect": "Allow",
                     "Principal": {
                                    "Service": "ec2.amazonaws.com"
                                  },
                     "Action": "sts:AssumeRole"
                    },
                    {
                      "Effect": "Allow",
                     "Principal": {
                                    "Service": "spotfleet.amazonaws.com"
                                  },
                     "Action": "sts:AssumeRole"
                    },
                    {
                      "Effect": "Allow",
                     "Principal": {
                                    "Service": "spot.amazonaws.com"
                                  },
                     "Action": "sts:AssumeRole"
                    }
                  ]
    }
  end

  def spot_fleet_role_name
    return 'spot_fleet_role_55fleets-revise9'
  end

  def find_or_create_spot_fleet_role
    name = spot_fleet_role_name


     @spot_fleet_role ||= client.get_role({role_name: name}).role rescue nil


    if !@spot_fleet_role
      @spot_fleet_role = create_spot_fleet_role
    else
      @spot_fleet_role = @spot_fleet_role
    end

    return @spot_fleet_role
  end
end
