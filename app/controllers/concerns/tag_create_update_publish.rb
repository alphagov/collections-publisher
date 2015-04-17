module TagCreateUpdatePublish
  extend ActiveSupport::Concern

  included do
    helper_method :parent, :parent_tags, :tag_type_label
  end

  module ClassMethods
    def tag_create_update_publish_for(klass)
      @tag_model = klass
      expose(:resource, model: symbolized_tag_model_name,
                        finder: :find_by_content_id)
    end

    def tag_model
      @tag_model
    end

    def symbolized_tag_model_name
      tag_model_name.underscore.to_sym
    end

    def tag_model_name
      tag_model.name
    end
  end

  def index
    @resource = resource
    render 'shared/tags/index'
  end

  def new
    @resource = resource
    render 'shared/tags/new'
  end

  def show
    @resource = resource
    render 'shared/tags/show'
  end

  def edit
    @resource = resource
    render 'shared/tags/edit'
  end

  def create
    @resource = resource
    @resource.attributes = tag_params

    if @resource.save
      PanopticonNotifier.create_tag(
        presenter_klass.new(@resource)
      )

      redirect_to polymorphic_path(@resource)
    else
      render 'shared/tags/new'
    end
  end

  def update
    @resource = resource
    if @resource.update_attributes(tag_params)
      PanopticonNotifier.update_tag(
        presenter_klass.new(@resource)
      )

      redirect_to polymorphic_path(@resource)
    else
      render 'shared/tags/edit'
    end
  end

  def publish
    @resource = resource
    @resource.publish!
    PanopticonNotifier.publish_tag(
      presenter_klass.new(@resource)
    )

    redirect_to polymorphic_path(@resource)
  end

private

  def tag_params
    params.require(self.class.symbolized_tag_model_name)
            .permit(:slug, :title, :description, :parent_id)
  end

  def parent_tags
    self.class.tag_model.only_parents
  end

  def tag_type_label
    self.class.tag_model_name.underscore.humanize
  end

  def parent
    @parent ||= self.class.tag_model.only_parents.find_by_id(parent_id)
  end

  def parent_id
    params[:parent_id] || params.fetch(self.class.symbolized_tag_model_name, {})[:parent_id]
  end

end
