class TaxonsController < ApplicationController
  before_filter :require_permissions!

  def index
    @taxons = Taxonomy::TaxonFetcher.new.taxons
  end

  def new
    @taxons_for_select = Taxonomy::TaxonFetcher.new.taxons_for_select
    @new_taxon = CreateTaxon.new
  end

  def create
    new_taxon = CreateTaxon.new(params[:create_taxon])
    new_taxon.create!
    redirect_to taxons_path
  end

  def edit
    @taxons_for_select = Taxonomy::TaxonFetcher.new.taxons_for_select

    content_item = Services.publishing_api.get_content(params[:id])
    links = Services.publishing_api.get_links(params[:id]).links

    @taxon = CreateTaxon.new(
      content_id: content_item.content_id,
      title: content_item.title,
      base_path: content_item.base_path,
      parent: links.parent.to_a.first,
    )
  end

  def update
    new_taxon = CreateTaxon.new(params[:create_taxon])
    new_taxon.create!
    redirect_to :back
  end

private

  def require_permissions!
    authorise_user!("Edit Taxonomy")
  end
end
