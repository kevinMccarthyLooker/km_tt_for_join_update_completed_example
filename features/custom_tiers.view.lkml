############
# Feature Description:
## User specifies any number of arbitrary cutoffs in a parameter
## takes field_to_tier's SQL field and groups data into tiers accordingly
#
# How to enable the feature:
## Add the following to a view and adjust label and sql parameters as desired
# extends: [custom_tiers]
# dimension: field_to_tier {
#   label: "Label for Resulting Tiered Field"
#   sql: ${field_to_be_tiered} ;;
# }

view: custom_tiers {

  extension: required

  #used in output field's label to remove the view name prefix
  dimension: view_name_label_holder {
    hidden: yes
    label: ""
  }

  parameter: compare_cutoffs__arbitrary{
    label: "Define Breakpoints for {{ field_to_tier._label | replace: view_name_label_holder._label , '' | strip }}"
    description: "Define Tiers using any number of comma separated breakpoints"
    suggestions: ["0,10,100","-50,50,150,300"]
    default_value: "0,10,100"
    type:string
  }

  dimension: field_to_tier {
    label: "Custom Tiered Field"
    hidden: yes
    sql:null;;
  }

  #field used for sorting and for Group Number Icon (in output field's HTML)
  dimension: tier_number {
    hidden: yes
    type: number
    sql:
    {% assign my_array = compare_cutoffs__arbitrary._parameter_value | remove: "'" | split: "," %}
    {% assign last_group_max_label = '-∞' %}
    {% assign element_counter = 0 %}
    case
    {%for element in my_array%}
    {% assign element_counter = element_counter | plus: 1 %}
    when ${field_to_tier}<{{element}} then {{element_counter}}
    {% assign last_group_max_label = element %}
    {%endfor%}
    {% assign element_counter = element_counter | plus: 1 %}
    when ${field_to_tier}>={{last_group_max_label}} then {{element_counter}}
    else {{last_group_max_label | plus: 1 }}
    end
    ;;
    value_format_name: id
  }

  #the output field that will reflect the custom groups on field_to_tier
  dimension: custom_tiered_field {
    label: "{{ field_to_tier._label | replace: view_name_label_holder._label , '' | strip }}"
    sql:
      {% assign my_array = compare_cutoffs__arbitrary._parameter_value | remove: "'" | split: "," %}
      {% assign last_group_max_label = '-∞' %}
      case
      {%for element in my_array%}
        when ${field_to_tier}<{{element}} then '{{last_group_max_label}}<= & <{{element}}'
        {% assign last_group_max_label = element %}
      {%endfor%}
        when ${field_to_tier}>={{last_group_max_label}} then '>={{last_group_max_label}}'
      else 'unknown'
      end;;
    order_by_field: tier_number
    html: <span class="label label-info">{{tier_number._rendered_value}}</span> {{rendered_value}} ;;
  }

}
