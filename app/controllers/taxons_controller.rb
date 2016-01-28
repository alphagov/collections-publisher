class TaxonsController < ApplicationController
  before_filter :require_permissions!

  def index
    @taxons = Taxonomy::TaxonFetcher.new.taxons
  end

  def new
    @taxons_for_select = Taxonomy::TaxonFetcher.new.taxons_for_select
    @new_taxon = TaxonForm.new
  end

  def create
    new_taxon = TaxonForm.new(params[:taxon_form])
    new_taxon.create!
    redirect_to taxons_path
  end

  def edit
    @taxons_for_select = Taxonomy::TaxonFetcher.new.taxons_for_select
    @taxon = TaxonForm.build(content_id: params[:id])
  end

  def update
    new_taxon = TaxonForm.new(params[:taxon_form])
    new_taxon.create!
    redirect_to :back
  end

private

  def require_permissions!
    authorise_user!("Edit Taxonomy")
  end
end
