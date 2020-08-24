class EnvConfig < ActiveRecord::Base
  belongs_to :app
  belongs_to :pod
  attr_encrypted :value,
                 key: ENV['ENV_KEY_SECRET'],
                 mode: :per_attribute_iv_and_salt,
                 algorithm: 'aes-256-cbc',
                 insecure_mode: true

  validates_uniqueness_of :name, scope: %i[app]

  def for_bash
    return "#{self.name}=\"#{self.value}\" "
  end
end
