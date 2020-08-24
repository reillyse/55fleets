class GithubRepo < Repo
  def self.model_name
    Repo.model_name
  end

  def add_key
    user.github.add_deploy_key(
      self.repo_name,
      '55fleets-deploy-key',
      self.public_deploy_key
    )
  end

  def add_url
    self.url = user.github.repo(self.repo_name).git_url
  end
end
