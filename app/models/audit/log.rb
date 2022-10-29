module Audit
  class Log < ApplicationRecord
    belongs_to :auditable, polymorphic: true
    belongs_to :character, optional: true

    serialize :details, JSON

    validates :action, presence: true
  end
end
