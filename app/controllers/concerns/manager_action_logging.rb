module ManagerActionLogging
     extend ActiveSupport::Concern

  private

       def log_manager_action(action:, record: nil, metadata: {})
            return unless respond_to?(:admin_signed_in?) && admin_signed_in?
            return if action.blank?
            begin
                 ManagerActionLog.create!(
                   admin: current_admin,
                   actor_name: current_admin.full_name.presence || current_admin.email,
                   actor_email: current_admin.email,
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
end
