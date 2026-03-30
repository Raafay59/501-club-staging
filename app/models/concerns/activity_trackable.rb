module ActivityTrackable
  extend ActiveSupport::Concern

  included do
    after_create_commit :record_created_activity
    after_update_commit :record_updated_activity
    after_destroy_commit :record_destroyed_activity
  end

  private

  def record_created_activity
    ActivityLog.record_change(record: self, action: :added)
  end

  def record_updated_activity
    return if ActivityLogMessage.meaningful_keys(previous_changes).empty?

    ActivityLog.record_change(record: self, action: :edited, saved_changes: previous_changes)
  end

  def record_destroyed_activity
    ActivityLog.record_change(record: self, action: :removed)
  end
end
