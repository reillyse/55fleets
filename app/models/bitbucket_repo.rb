class BitbucketRepo < Repo
  def self.model_name
    Repo.model_name
  end

  def add_key
    user.bb.repos.keys.create(
      user.uid,
      self.repo_name,
      label: 'newtrial', key: self.public_deploy_key
    )
  end

  def add_url
    self.url = "git@bitbucket.org:#{user.uid}/#{self.repo_name}.git"
  end
end
