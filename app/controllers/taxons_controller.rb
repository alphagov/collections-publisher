class TaxonsController < ApplicationController
  before_filter :require_permissions!

  def index
    @taxons = taxon_fetcher.taxons
  end

  def new
    render :new, locals: {
      taxon_form: TaxonForm.new,
      taxons_for_select: taxons_for_select,
    }
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
    render :edit, locals: {
      taxon_form: taxon_form,
      taxons_for_select: taxons_for_select,
    }
  end

  def update
    new_taxon = TaxonForm.new(params[:taxon_form])
    new_taxon.create!
    redirect_to taxons_path
  end

private

  def taxons_for_select
    taxon_fetcher.taxons_for_select
  end

  def taxon_parents
    taxon_fetcher.parents_for_taxon_form(taxon_form)
  end

  def taxon_fetcher
    @taxon_fetcher ||= Taxonomy::TaxonFetcher.new
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
