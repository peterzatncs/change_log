ActiveRecord::Schema.define do

  create_table "test" do |t|
    t.column "total",     :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end


  create_table "change_logs"  do |t|
    t.column "id", :integer, :null => false
    t.column "version",   :integer, :null => false
    t.column "record_id",   :integer
    t.column "table_name", :string
    t.column "field_type", :string
    t.column "attribute_name", :string
    t.column "action", :string
    t.column "user", :string
    t.column "old_value", :string
    t.column "new_value", :string
    t.timestamps
  end

end
