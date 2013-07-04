module ChangeLog
  module Model

    def self.included(base)
      base.send :extend, ClassMethods
    end


    module ClassMethods
      # Declare this in your model to keep a change log for every create, update, and destroy.
      #
      # Options:
      # :ignore    an array of attributes will be ingored when saving changes into change log.
      def enable_change_log(options = {})
        send :include, InstanceMethods

        cattr_accessor :ignore, :whodidit
        self.ignore = (options[:ignore] || []).map &:to_s

        # Indicates whether or not ChangeLog is active for this class.
        # This is independent of whether ChangeLog is globally enabled or disabled.
        cattr_accessor :change_log_active
        self.change_log_active = true

        after_create  :record_create
        before_update :record_update
        after_destroy :record_destroy
      end

      # Switches ChangeLog off for this class.
      def change_log_off
        self.change_log_active = false
      end

      # Switches ChangeLog on for this class.
      def change_log_on
        self.change_log_active = true
      end
    end

    # Wrap the following methods in a module so we can include them only in the
    # ActiveRecord models that declare `enable_change_log`.
    module InstanceMethods

      def record_create
        # do nothing if the change log is not turned on
        return '' unless switched_on?
        changes = []
        # saving changes to change log
        self.attributes.map do |key,value|
          unless self.ignore.include?(key.to_sym)
            changes << {:action=>'INSERT', :record_id=>self.id,:table_name=>self.class.table_name, :user=>ChangeLog.whodidit,:attribute_name=>key,:new_value=>value,:version=>1}
          end
        end  
        ChangeLogs.update_change_log_record_with(changes)
  	  end

      def record_update
        # do nothing if the change log is not turned on and no changes has been made
        return '' unless switched_on? && self.valid? && self.changed?
        changes = []
        # saving changes to change log
        self.changes.each do |attribute_name,value|
          # do not record changes between nil <=> ''
          # and ignore the changes for ignored columns
          unless value[1].eql?(value[0]) || (value[1].blank?&&value[0].blank?) || self.ignore.include?(attribute_name.to_s)
            changes << {:action=>'UPDATE',:record_id=>self.id,:table_name=>self.class.table_name,:user=>ChangeLog.whodidit,:attribute_name=>attribute_name,:old_value=>value[0],:new_value=>value[1],:version => ChangeLogs.get_version_number(self.id,self.class.table_name)}
          end
        end  
        ChangeLogs.update_change_log_record_with(changes)
      end

      def record_destroy
        return '' unless switched_on?
        changes = [{:action=>'DELETE',:table_name=>self.class.table_name,:record_id=>self.id,:user=>ChangeLog.whodidit,:version => ChangeLogs.get_version_number(self.id,self.class.table_name)}]
        ChangeLogs.update_change_log_record_with(changes)
      end

      # Return a list of change_log records
      # Return empty array if not record found
      def change_logs
        return ChangeLogs.where(['table_name= ? and record_id = ?',self.class.table_name,self.id]).order("created_at DESC")
      end

      # Return `true` if current record has a list of change_log records
      # otherwise `false`.
      def has_change_log?
        return (ChangeLogs.count(:conditions=>['table_name= ? and record_id = ?',self.class.table_name,self.id]) > 0) ? true : false
      end

      private

      # Returns `true` if ChangeLog is globally enabled and active for this class,
      # `false` otherwise.
      def switched_on?
        ChangeLog.enabled? && self.class.change_log_active
      end    
    end

  end
end

ActiveRecord::Base.send :include, ChangeLog::Model
