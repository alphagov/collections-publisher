class ImportRouterDataTopicRedirects < ActiveRecord::Migration
  def up
    @redirects = []
    Redirect.transaction do
      create_redirects
    end

    # register the redirects so the paths get claimed in url-arbiter
    register_redirects
  end

  def create_redirects
    # /childrens-services,/topic/schools-colleges-childrens-services
    schools_colleges_childrens_services = Topic.only_level_one.find_by!(:slug => 'schools-colleges-childrens-services')
    @redirects << Redirect.create!(
      :tag => schools_colleges_childrens_services,
      :original_tag_base_path => "/childrens-services",
      :from_base_path => "/childrens-services",
      :to_base_path => schools_colleges_childrens_services.base_path,
    )
    {
      "adoption" => "adoption-fostering",
      "child-poverty" => "support-for-children-young-people",
      "childrens-social-care" => "looked-after-children",
      "data-collection" => "data-collection-statistical-returns",
      "early-learning-childcare" => "early-years",
      "family-support" => "support-for-children-young-people",
      "foster-care" => "adoption-fostering",
      "safeguarding-children" => "safeguarding-children",
      "special-educational-needs" => "special-educational-needs-disabilities",
      "young-peoples-support" => "support-for-children-young-people",
    }.each do |old_slug, new_slug|
      new_tag = schools_colleges_childrens_services.children.find_by!(:slug => new_slug)
      @redirects << Redirect.create!(
        :tag => new_tag,
        :original_tag_base_path => "/childrens-services/#{old_slug}",
        :from_base_path => "/childrens-services/#{old_slug}",
        :to_base_path => new_tag.base_path,
      )
    end

    # /commercial-fishing-fisheries/monitoring-enforcement,/topic/commercial-fishing-fisheries/regulations-monitoring-enforcement
    # /commercial-fishing-fisheries/regulations-restrictions,/topic/commercial-fishing-fisheries/regulations-monitoring-enforcement
    commercial_fishing_fisheries = Topic.only_level_one.find_by!(:slug => 'commercial-fishing-fisheries')
    {
      "monitoring-enforcement" => "regulations-monitoring-enforcement",
      "regulations-restrictions" => "regulations-monitoring-enforcement",
    }.each do |old_slug, new_slug|
      new_tag = commercial_fishing_fisheries.children.find_by!(:slug => new_slug)
      @redirects << Redirect.create!(
        :tag => new_tag,
        :original_tag_base_path => "/commercial-fishing-fisheries/#{old_slug}",
        :from_base_path => "/commercial-fishing-fisheries/#{old_slug}",
        :to_base_path => new_tag.base_path,
      )
    end

    competition = Topic.only_level_one.find_by!(:slug => 'competition')
    [
      "business-law-compliance",
      "competition-law-compliance",
      "consumer-protection-regulations",
      "criminal-cartels",
      "reviews-orders-undertakings",
      "unfair-terms-regulations-compliance",
    ].each do |slug|
      @redirects << Redirect.create!(
        :tag => competition,
        :original_tag_base_path => "/competition/#{slug}",
        :from_base_path => "/competition/#{slug}",
        :to_base_path => competition.base_path,
      )
    end

    {
      "ca98-civil-cartels" => "competition-act-cartels",
      "consumer-law-enforcement" => "consumer-protection",
    }.each do |old_slug, new_slug|
      new_tag = competition.children.find_by!(:slug => new_slug)
      @redirects << Redirect.create!(
        :tag => new_tag,
        :original_tag_base_path => "/competition/#{old_slug}",
        :from_base_path => "/competition/#{old_slug}",
        :to_base_path => new_tag.base_path,
      )
    end

    # /health-protection/migrant-health,/topic/health-protection
    health_protection = Topic.only_level_one.find_by!(:slug => 'health-protection')
    @redirects << Redirect.create!(
      :tag => health_protection,
      :original_tag_base_path => "/health-protection/migrant-health",
      :from_base_path => "/health-protection/migrant-health",
      :to_base_path => health_protection.base_path,
    )

    # /paye,/topic/business-tax/paye
    paye = Topic.joins(:parent).find_by!(:parents_tags => { :slug => 'business-tax' }, :slug => 'paye')
    [
      "/paye",
      "/paye/annual-tasks",
      "/paye/business-changes",
      "/paye/employees",
      "/paye/expenses-benefits",
      "/paye/introduction",
      "/paye/news-updates",
      "/paye/registering-getting-started",
      "/paye/regular-tasks",
      "/paye/special-types-employee-pay",
      "/paye/statutory-leave-pay",
    ].each do |old_path|
      @redirects << Redirect.create!(
        :tag => paye,
        :original_tag_base_path => old_path,
        :from_base_path => old_path,
        :to_base_path => paye.base_path,
      )
    end

    # /schools-colleges,/topic/schools-colleges-childrens-services
    schools_colleges_childrens_services = Topic.only_level_one.find_by!(:slug => 'schools-colleges-childrens-services')
    @redirects << Redirect.create!(
      :tag => schools_colleges_childrens_services,
      :original_tag_base_path => "/schools-colleges",
      :from_base_path => "/schools-colleges",
      :to_base_path => schools_colleges_childrens_services.base_path,
    )
    {
      "academies-free-schools" => "opening-academy-free-school",
      "administration-finance" => "school-college-funding-finance",
      "behaviour-attendance" => "school-behaviour-attendance",
      "careers-employment" => "school-careers-employment",
      "curriculum-qualifications" => "curriculum-qualifications",
      "data-collection" => "data-collection-statistical-returns",
      "early-learning-childcare" => "early-years",
      "governance" => "running-school-college",
      "safeguarding-children" => "safeguarding-children",
      "special-educational-needs" => "special-educational-needs-disabilities",
      "young-peoples-support" => "support-for-children-young-people",
    }.each do |old_slug, new_slug|
      new_tag = schools_colleges_childrens_services.children.find_by!(:slug => new_slug)
      @redirects << Redirect.create!(
        :tag => new_tag,
        :original_tag_base_path => "/schools-colleges/#{old_slug}",
        :from_base_path => "/schools-colleges/#{old_slug}",
        :to_base_path => new_tag.base_path,
      )
    end
  end

  def register_redirects
    publishing_api = Services.publishing_api

    @redirects.group_by(&:original_tag_base_path).each do |old_base_path, redirects|
      presenter = RedirectPresenter.new(redirects)
      publishing_api.put_content_item(old_base_path, presenter.render_for_publishing_api)
    end
  end
end
