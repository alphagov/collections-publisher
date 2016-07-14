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

  def show
    render :show, locals: {
      taxon_form: taxon_form,
      tagged: tagged,
      taxon_parents: taxon_parents,
    }
  end

  def edit
    @taxons_for_select = Taxonomy::TaxonFetcher.new.taxons_for_select
    @taxon = TaxonForm.build(content_id: params[:id])
  end

  def update
    new_taxon = TaxonForm.new(params[:taxon_form])
    new_taxon.create!
    redirect_to taxons_path
  end

private

  def taxon_parents
    Taxonomy::TaxonFetcher.new.parents_for_taxon_form(taxon_form)
  end

  def taxon_form
    TaxonForm.build(content_id: params[:id])
  end

  def tagged
    Services.content_store.incoming_links!(
      taxon_form.base_path,
      types: ["alpha_taxons"],
    ).alpha_taxons
  end

  def require_permissions!
    authorise_user!("Edit Taxonomy")
  end
end
