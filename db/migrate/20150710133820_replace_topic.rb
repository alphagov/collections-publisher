class ReplaceTopic < ActiveRecord::Migration
  def up
    # /topic/environmental-management/climate-change-energy
    old_subtopic = Topic.find_by(:content_id => "19185a99-77a8-41e2-b327-bcc6e69a44b8")
    if old_subtopic.nil?
      puts "WARNING: Failed to find old topic"
      return
    end
    # /topic/climate-change-energy
    new_topic = Topic.find_by(:content_id => "57c6699d-ceda-4168-9d23-3fed774ca776")
    if new_topic.nil?
      puts "WARNING: Failed to find new topic"
      return
    end

    old_subtopic.redirects.each do |redirect|
      redirect.update_attributes!(:tag => new_topic, :to_base_path => new_topic.base_path)
    end

    [
      "",
      "/latest",
      "/email-signup",
    ].each do |suffix|
      Redirect.create!(
        :tag => new_topic,
        :original_tag_base_path => old_subtopic.base_path,
        :from_base_path => old_subtopic.base_path + suffix,
        # redirect to the bare base_path because top-level topics don't have latest pages etc.
        :to_base_path => new_topic.base_path,
      )
    end

    old_subtopic.destroy
  end
end
