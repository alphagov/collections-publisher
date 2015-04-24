class MakeTopicIdNotNull < ActiveRecord::Migration
  def change
    change_column_null :lists, :topic_id, false
  end
end
