module Admin::Resources::DataTypes::HasManyHelper

  def has_many_filter(filter)
    att_assoc = @resource.reflect_on_association(filter.to_sym)
    class_name = att_assoc.options[:class_name] || filter.classify
    resource = class_name.constantize

    items = [[Typus::I18n.t("View all %{attribute}", :attribute => @resource.human_attribute_name(filter).downcase.pluralize), ""]]
    items += resource.order(resource.typus_order_by).map { |v| [v.to_label, v.id] }
  end

  alias_method :has_and_belongs_to_many_filter, :has_many_filter

  def typus_form_has_many(field)
    setup_relationship(field)

    if @reflection.type.nil?
      options = { "resource[#{@reflection.foreign_key}]" => @item.id }
    else
      options = {"resource[#{@reflection.type}]" => @item.class.to_s, "resource[#{@reflection.foreign_key}]" => @item.id }
    end

    if @reflection.options && (as = @reflection.options[:as])
      klass = @resource.is_sti? ? @resource.superclass : @resource
      options.merge!("#{as}_type" => klass)
    end

    build_pagination
    set_has_many_resource_actions

    locals = { :association_name => @association_name,
               :add_new => build_add_new_for_has_many(@model_to_relate, field, options),
               :table => build_relationship_table }

    render "admin/templates/has_many", locals
  end

  def build_add_new_for_has_many(klass, field, options = {})
    if admin_user.can?("create", klass)
      default_options = { :controller => "/admin/#{klass.to_resource}",
                          :action => "new",
                          :_popup => true }

      link_to Typus::I18n.t("Add New"), default_options.merge(options), { :class => "iframe" }
    end
  end

  def set_has_many_resource_actions
    @resource_actions = [["Edit", { :action => "edit", :_popup => true }, { :class => 'iframe' }],
                         ["Trash", { :action => "destroy" }, { :confirm => "Trash?" } ]]
  end

end
