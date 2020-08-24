class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  devise :omniauthable, omniauth_providers: %i[bitbucket github]

  has_many :apps
  has_many :repos
  has_many :certs
  has_many :fleets, through: :apps

  validates_uniqueness_of :email, scope: :provider

  def self.from_omniauth_bitbucket(auth)
    where(provider: auth.provider, email: auth.info.email)
      .first_or_create! do |user|
      #swapped email for uid
      user.uid =
        auth.uid
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name # assuming the user model has a name
      user.image = auth.info.avatar # assuming the user model has an image
      user.oauth_token = auth.credentials.token
      user.oauth_secret = auth.credentials.secret
    end
  end

  def self.from_omniauth_github(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name # assuming the user model has a name
      user.image = auth.info.avatar # assuming the user model has an image
      user.oauth_token = auth.credentials.token
      user.oauth_secret = auth.credentials.secret
    end
  end

  def bb
    @bitbucket ||=
      BitBucket.new oauth_token: self.oauth_token,
                    oauth_secret: self.oauth_secret
  end

  def github
    #   @client ||= Octokit::Client.new(:access_token => self.oauth_token)
    #@client ||= Octokit::Client.new(:client_id => ENV["GITHUB_KEY"], :client_secret => ENV["GITHUB_SECRET"])

    Octokit::Client.new(access_token: self.oauth_token)
  end
end
