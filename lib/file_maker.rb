class FileMaker
  def initialize(tag_type, parent_base_path)
    @tag_type = tag_type
    @parent_base_path = parent_base_path
  end

  attr_reader :tag_type, :parent_base_path

  def make_directory
    unless File.directory?(tag_type)
      FileUtils.mkdir_p(tag_type)
    end
  end

  def file_path
    "#{tag_type}/tagged_to_#{parent_topic}.csv"
  end

private

  def parent_topic
    parent_base_path.split("/").last
  end
end
