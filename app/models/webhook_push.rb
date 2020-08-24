class WebhookPush
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  def self.create_from_webhook(data)
    WebhookPush.create!(JSON.parse(data.to_json))
  end
end
