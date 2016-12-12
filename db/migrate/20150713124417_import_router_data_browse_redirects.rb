class ImportRouterDataBrowseRedirects < ActiveRecord::Migration
  def up
    @redirects = []
    Redirect.transaction do
      create_redirects
    end

    # register the redirects so the paths get claimed in url-arbiter
    register_redirects
  end

  def create_redirects
    # /browse/births-deaths-marriages/registry-offices,/browse/births-deaths-marriages/register-offices
    register_offices = MainstreamBrowsePage.joins(:parent).find_by!(:parents_tags => { :slug => "births-deaths-marriages" }, :slug => "register-offices")
    @redirects << Redirect.create!(
      :tag => register_offices,
      :original_tag_base_path => "/browse/births-deaths-marriages/registry-offices",
      :from_base_path => "/browse/births-deaths-marriages/registry-offices",
      :to_base_path => register_offices.base_path,
    )

    # /browse/citizenship/coasts-countryside,/browse/environment-countryside
    environment_countryside = MainstreamBrowsePage.only_parents.find_by!(:slug => 'environment-countryside')
    @redirects << Redirect.create!(
      :tag => environment_countryside,
      :original_tag_base_path => "/browse/citizenship/coasts-countryside",
      :from_base_path => "/browse/citizenship/coasts-countryside",
      :to_base_path => environment_countryside.base_path,
    )

    # /browse/driving/passports-travelling-abroad,/browse/abroad
    abroad = MainstreamBrowsePage.only_parents.find_by!(:slug => 'abroad')
    @redirects << Redirect.create!(
      :tag => abroad,
      :original_tag_base_path => "/browse/driving/passports-travelling-abroad",
      :from_base_path => "/browse/driving/passports-travelling-abroad",
      :to_base_path => abroad.base_path,
    )
    # /browse/citizenship/passports,/browse/abroad/passports
    passports = abroad.children.find_by!(:slug => 'passports')
    @redirects << Redirect.create!(
      :tag => passports,
      :original_tag_base_path => "/browse/citizenship/passports",
      :from_base_path => "/browse/citizenship/passports",
      :to_base_path => passports.base_path,
    )

    # /browse/housing,/browse/housing-local-services
    housing_local_services = MainstreamBrowsePage.only_parents.find_by!(:slug => 'housing-local-services')
    @redirects << Redirect.create!(
      :tag => housing_local_services,
      :original_tag_base_path => "/browse/housing",
      :from_base_path => "/browse/housing",
      :to_base_path => housing_local_services.base_path,
    )
    [
      "council-housing-association",
      "council-tax",
      "landlords",
      "local-councils",
      "noise-neighbours",
      "owning-renting-property",
      "planning-permission",
      "recycling-rubbish",
      "repossessions-evictions",
      "safety-environment",
    ].each do |slug|
      new_tag = housing_local_services.children.find_by!(:slug => slug)
      @redirects << Redirect.create!(
        :tag => new_tag,
        :original_tag_base_path => "/browse/housing/#{slug}",
        :from_base_path => "/browse/housing/#{slug}",
        :to_base_path => new_tag.base_path,
      )
    end

    visas_immigration = MainstreamBrowsePage.only_parents.find_by!(:slug => 'visas-immigration')
    {
      "after-youve-applied" => "manage-your-application",
      "employers-sponsorship" => "sponsor-workers-students",
      "long-stay-visas" => "family-visas",
      "long-visit-visas" => "family-visas",
      "settling-in-the-uk" => "settle-in-the-uk",
      "short-stay-visas" => "tourist-short-stay-visas",
      "short-visit-visas" => "tourist-short-stay-visas",
      "sponsoring-workers-students" => "sponsor-workers-students",
      "study-visas" => "student-visas",
      "visit-visas" => "tourist-short-stay-visas",
      "working-visas" => "work-visas",
      "your-visa" => "manage-your-application",
    }.each do |old_slug, new_slug|
      new_tag = visas_immigration.children.find_by!(:slug => new_slug)
      @redirects << Redirect.create!(
        :tag => new_tag,
        :original_tag_base_path => "#{visas_immigration.base_path}/#{old_slug}",
        :from_base_path => "#{visas_immigration.base_path}/#{old_slug}",
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
