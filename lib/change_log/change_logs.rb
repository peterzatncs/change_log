class ChangeLogs < ActiveRecord::Base
  # Set table name to "change_logs" 
  self.table_name = :change_logs

  private

  # Save Change Log details with changes 
  def self.update_change_log_record_with(changes=[])
    records = []
    changes.each do |option|
      record = ChangeLogs.new(option)
      record.field_type = get_field_type(option[:table_name],option[:attribute_name]) unless option[:action].eql?('DELETE')
      record.user = option[:user].id unless option[:user].is_a?(String)
      record.created_at = Time.now
      records << record
    end
    ChangeLogs.import records
  end

  # return the latest version number for this change
  def self.get_version_number(id,table_name)
    latest_version = ChangeLogs.maximum(:version,:conditions=>['record_id = ? and table_name = ?',id,table_name])
    return latest_version.nil? ? 1 : latest_version.next
  end

  def self.get_field_type(table_name,field_name)
    return 'Error' if table_name.blank?||field_name.blank?
    ActiveRecord::Base.connection.columns(table_name).each do |field|
      return field.sql_type if field.name.eql?(field_name)
    end
  rescue
    return 'Error'
  end

end
