module Auditable
  extend ActiveSupport::Concern

  module ClassMethods
    def auditable_attributes
      @auditable_attributes || []
    end

    def auditable_attributes=(*attr_names)
      @auditable_attributes = attr_names.flatten
    end
  end

  included do
    has_many :audit_logs, class_name: "Audit::Log",
      as: :auditable,
      inverse_of: :auditable,
      dependent: :destroy

    after_create :log_created
    after_update :log_updated
  end

  def log_event(action, **particulars)
    Audit::Log.create!(
      action: action,
      auditable: self,
      character: Current.character,
      details: particulars
    )
  end

  private

  def log_created
    log_event :created, **particular_changes
  end

  def log_updated
    log_event :updated, **particular_changes
  end

  def particular_changes
    previous_changes.slice(*self.class.auditable_attributes)
  end
end
