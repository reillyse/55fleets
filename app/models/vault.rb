class Vault < ActiveRecord::Base
  attr_encrypted :data,
                 key: ENV['GSG_KEY_SECRET'],
                 mode: :per_attribute_iv_and_salt,
                 algorithm: 'aes-256-cbc',
                 insecure_mode: true
end
