module ChangeLog
  module Controller

    def self.included(base)
      base.before_filter :set_change_log_whodidit
    end

    protected

    # Returns the user who is responsible for any changes that occur.
    # By default this calls `current_user` and returns the result.
    # 
    # Override this method in your controller to call a different
    # method, e.g. `current_login_user`, or anything.
    def user_for_change_log
      current_user rescue nil
    end

    private

    # Tells ChangeLog who is responsible for any changes.
    def set_change_log_whodidit
      ::ChangeLog.whodidit = user_for_change_log
    end

  end
end

ActionController::Base.send :include, ChangeLog::Controller