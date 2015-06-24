class AddRedirectsForTopicsNamespace < ActiveRecord::Migration
  def up
    Topic.published.only_parents.each do |topic|
      original_topic_base_path = '/' + topic.full_slug

      Redirect.create!(
        tag: topic,
        original_topic_base_path: original_topic_base_path,
        from_base_path: original_topic_base_path,
        to_base_path: '/topic' + original_topic_base_path
      )
    end

    Topic.published.only_children.each do |topic|
      original_topic_base_path = '/' + topic.full_slug

      Redirect.create!(
        tag: topic,
        original_topic_base_path: original_topic_base_path,
        from_base_path: original_topic_base_path,
        to_base_path: '/topic' + original_topic_base_path
      )

      Redirect.create!(
        tag: topic,
        original_topic_base_path: original_topic_base_path,
        from_base_path: original_topic_base_path + '/email-signup',
        to_base_path: '/topic' + original_topic_base_path + '/email-signup'
      )

      Redirect.create!(
        tag: topic,
        original_topic_base_path: original_topic_base_path,
        from_base_path: original_topic_base_path + '/latest',
        to_base_path: '/topic' + original_topic_base_path + '/latest'
      )
    end
  end

  def down
  end
end
