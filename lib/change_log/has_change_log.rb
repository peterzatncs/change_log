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

      # NOTE::This version's change_log is temporarily locked down to Rails 2.3.x
      # and mysql database. Another version with fully support to Rails 3.x and multiple databases 
      # will be available soon in another branch on github.
      def record_create
        # do nothing if the change log is not turned on
        return '' unless switched_on?

        # generate the single sql insert statement
        column_values = []
        # saving changes to change log
        self.attributes.map do |key,value|
          unless self.ignore.include?(key.to_sym)
            field_type = ChangeLogs.get_field_type(self.class.table_name,key)
            value = value.gsub("'", %q(\\\')) unless value.blank? || !value.is_a?(String)
            column_values << '(' + ["'INSERT'", self.id, "'#{self.class.table_name}'", "'#{ChangeLog.whodidit}'", "'#{field_type}'", "'#{key}'", "'#{value}'",1].join(',') + ')'
          end
        end  
        column_names = ['action','record_id','table_name','user','field_type','attribute_name','new_value','version']
        insert_statement = "INSERT INTO `#{ChangeLogs.table_name}` (`#{column_names.join('`, `')}`) VALUES " + column_values.join( ',' ) + ";"
        ActiveRecord::Base.connection.execute( insert_statement )
  	  end

      # NOTE::This version's change_log is temporarily locked down to Rails 2.3.x
      # and mysql database. Another version with fully support to Rails 3.x and multiple databases 
      # will be available soon in another branch on github.
      def record_update
        # do nothing if the change log is not turned on and no changes has been made
        return '' unless switched_on? && self.valid? && self.changed?

        # generate the single sql insert statement
        column_values = []
        # saving changes to change log
        self.changes.each do |attribute_name,value|
          # do not record changes between nil <=> ''
          # and ignore the changes for ignored columns
          unless value[1].eql?(value[0]) || (value[1].blank?&&value[0].blank?) || self.ignore.include?(attribute_name.to_s)
            field_type = ChangeLogs.get_field_type(self.class.table_name,attribute_name)
            value[0] = value[0].gsub("'", %q(\\\')) unless value[0].blank? || !value[0].is_a?(String)
            value[1] = value[1].gsub("'", %q(\\\')) unless value[1].blank? || !value[1].is_a?(String)

            column_values << '(' + ["'UPDATE'", self.id, "'#{self.class.table_name}'", "'#{ChangeLog.whodidit}'","'#{field_type}'", "'#{attribute_name}'", "'#{value[0]}'","'#{value[1]}'",ChangeLogs.get_version_number(self.id,self.class.table_name)].join(',') + ')'
          end
        end  
        column_names = ['action','record_id','table_name','user','field_type','attribute_name','old_value','new_value','version']
        insert_statement = "INSERT INTO `#{ChangeLogs.table_name}` (`#{column_names.join('`, `')}`) VALUES " + column_values.join( ',' ) + ";"
        ActiveRecord::Base.connection.execute( insert_statement )
      end

      def record_destroy
        return '' unless switched_on?
        ChangeLogs.update_change_log_record_with({:action=>'DELETE',:table_name=>self.class.table_name,:record_id=>self.id,:user=>ChangeLog.whodidit,:version => ChangeLogs.get_version_number(self.id,self.class.table_name)})
      end

      # Return a list of change_log records
      # Return empty array if not record found
      def change_logs
        return ChangeLogs.find(:all,:conditions=>['table_name= ? and record_id = ?',self.class.table_name,self.id],:order=>"created_at DESC")
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
