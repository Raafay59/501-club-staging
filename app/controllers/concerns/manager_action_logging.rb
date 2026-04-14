# frozen_string_literal: true

module ManagerActionLogging
  extend ActiveSupport::Concern

  private

  def log_manager_action(action:, record: nil, metadata: {})
    return unless respond_to?(:organizer_tools?) && organizer_tools?
    return if action.blank?

    ManagerActionLog.create!(
      user: current_user,
      action: action,
      record_type: record&.class&.name,
      record_id: record&.id,
      metadata: metadata || {},
      ip_address: request.remote_ip,
      user_agent: request.user_agent.to_s.first(500)
    )
  rescue StandardError
    # Never block manager actions if logging fails.
    nil
  end
end
