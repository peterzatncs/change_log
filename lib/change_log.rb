require 'singleton'
require 'yaml'
require 'change_log/config'
require 'change_log/controller'
require 'change_log/has_change_log'
require 'change_log/change_logs'

# ChangeLog's module methods can be called in both models and controllers.
module ChangeLog

  # Switches ChangeLog on or off.
  def self.enabled=(value)
    ChangeLog.config.enabled = value
  end

  # Returns `true` if ChangeLog is on, `false` otherwise.
  # ChangeLog is enabled by default.
  def self.enabled?
    !!ChangeLog.config.enabled
  end

  # Returns who is responsible for any changes that occur.
  def self.whodidit
    change_log_store[:whodidit]
  end

  # Sets who is responsible for any changes that occur.
  # In a controller it automatically get the value from `current_user` action.
  def self.whodidit=(value)
    change_log_store[:whodidit] = value
  end
  
  
  private
  # Thread-safe hash to hold ChangeLog's data.
  def self.change_log_store
    Thread.current[:change_log] ||= {}
  end

  # Returns ChangeLog's configuration object.
  def self.config
    @@config ||= ChangeLog::Config.instance
  end

end