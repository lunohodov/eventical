class Current < ActiveSupport::CurrentAttributes
  attribute :character
  attribute :ip_address, :request_id, :user_agent
end
