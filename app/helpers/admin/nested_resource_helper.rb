module Admin::NestedResourceHelper

  def apply_filters(collection)
    collection = apply_scope(collection)
    collection = apply_order(collection)
    collection = apply_page(collection)
    return collection
  end

  def apply_order(collection)
    if params[:order] && params[:order] =~ /^([\w\_\.]+)_(desc|asc)$/
      column = $1
      order  = $2
      collection.reorder("#{column} #{order}")
    else
      collection
    end
  end

  def apply_scope(collection)
    scope = params[:scope]
    if scope && collection.respond_to?(scope)
      collection.unscoped.send(scope)
    else
      collection
    end
  end

  def apply_page(collection)
    collection.page(params[:page]).per(10)
  end

  def nested_resource_actions(resource, nested_resource)
    [
      link_to("View",  [ :admin, resource, nested_resource ]),
      link_to("Edit", [ :edit, :admin, resource, nested_resource ]),
      link_to("Delete", [ :admin, resource, nested_resource ], method: :delete)
    ].join(', ').html_safe
  end

  def nested_resource_scope(scope)
    classes = []
    classes << :scope
    classes << scope
    classes << :selected if request.query_parameters[:scope].to_s == scope.to_s

    content_tag :li, class: classes.compact.join(" ") do
      link_to scope.to_s.capitalize, request.query_parameters.merge(scope: scope), class: "table_tools_button"
    end
  end

  class NestedResourcePaginatedCollection < ActiveAdmin::Views::PaginatedCollection

    builder_method :nested_resource_paginated_collection

    def build(collection, options = {})
      @nested_resource_name = options.fetch(:nested_resource_name)
      super
    end

    def build_download_format_links(formats = [:csv, :xml, :json])
      links = formats.collect {|f| download_link(f) }
      div :class => "download_links" do
        text_node [I18n.t('active_admin.download'), links].flatten.join("&nbsp;").html_safe
      end
    end

    private

    def download_link(format)
      link_to format.to_s.upcase, polymorphic_url(
        [ :admin, resource, @nested_resource_name ],
        { format: format }.merge( request.query_parameters.except(:commit, :format) )
      )
    end

  end

end
