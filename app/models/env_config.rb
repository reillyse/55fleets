class EnvConfig < ActiveRecord::Base
  belongs_to :app
  belongs_to :pod
  attr_encrypted :value, :key => ENV["ENV_KEY_SECRET"], :mode => :per_attribute_iv_and_salt

  validates_uniqueness_of :name, :scope =>[:app]

  def for_bash
    return "#{self.name}=\"#{self.value}\" "
  end
end
