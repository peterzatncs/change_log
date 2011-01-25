require 'rubygems'
require 'test/unit'
require 'lib/activerecord_test_case'
require 'action_controller'
require 'change_log'

class ChangeLogTest < ActiveRecordTestCase
  fixtures :change_logs

  # insert an new record
  # then check the total number
  def test_update_change_log_record_with
    option = {:action=>'INSERT', :record_id=>3,:table_name=>'test', :user=>'test',:attribute_name=>'test',:new_value=>'50',:version=>1}
    assert_equal true, ChangeLogs.update_change_log_record_with(option) 
    assert_equal 3, ChangeLogs.count()
  end

  # it should pick up the largest version number from fixture file
  def test_get_version_number
    assert_equal 3, ChangeLogs.get_version_number(1,'test')
  end

  # it will get the type of field from the table
  def test_get_field_type
    assert_equal 'integer', ChangeLogs.get_field_type('test','total')
  end

  # some logic test
  def test_change_log_logic
      # find a test, update the total
      version_number = ChangeLogs.get_version_number(1,'test')
      option = {:action=>'UPDATE', :record_id=>1,:table_name=>'test', :user=>'peterz',:attribute_name=>'test',:new_value=>'999',:old_value=>'100',:version=>version_number}
      assert_equal true, ChangeLogs.update_change_log_record_with(option)
      change_log = ChangeLogs.find(version_number)
      assert_equal 'peterz',change_log.user
      assert_equal '999', change_log.new_value
      assert_equal '100', change_log.old_value
  end
end
