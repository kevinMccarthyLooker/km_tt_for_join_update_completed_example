###############
#Sequencing Block source file. include in your model file. instructions documented separately

#template to hide user input fields
view: sequence_input {
  #Update with fields that are valid together in an explore:
  dimension: input_parent_unique_id__dimension  {hidden:yes}
  dimension: input_child_unique_id__dimension   {hidden:yes}
  dimension: order_by_dimension                 {hidden:yes}#must be same as child field or have a one_to_one relationship (ie id and created_time is ok)
  dimension: order_by_descending_toggle         {sql:false;; hidden:yes}
  dimension: order_by_descending_text_for_sql {hidden: yes
    sql:{% if order_by_descending_toggle._sql == 'true' %}DESC{% endif %};;
  }
  measure: order_by_measure {
    hidden: yes
    sql:null    ;;
  }
}

#placeholder explore that pre-defines joins that will be used to join back to the original explore
explore: sequence_input_explore_placeholder {
  extension: required
  join: sequence_input {sql:;;relationship:one_to_one}#will be overridden
}

view: sequencing_ndt {
  extension: required
  derived_table: {
    explore_source: sequence_input_explore {
      timezone: "query_timezone"
      column: parent_unique_id    {field:sequence_input.input_parent_unique_id__dimension}
      column: child_unique_id     {field:sequence_input.input_child_unique_id__dimension}#
      column: order_by_dimension  {field:sequence_input.order_by_dimension}
      column: order_by_measure    {field:sequence_input.order_by_measure}
      derived_column: sequence_number {sql:ROW_NUMBER() OVER(PARTITION BY parent_unique_id ORDER BY order_by_dimension,order_by_measure;;}
    }
  }

  dimension: parent_unique_id   {hidden: yes}
  dimension: child_unique_id    {hidden:yes}
  dimension: order_by_dimension {hidden:yes}#must be same as child field or have a one_to_one relationship (ie id and created_time is ok)
  dimension: order_by_measure     {hidden:yes}#must be same as child field or have a one_to_one relationship (ie id and created_time is ok)

  dimension: sequence_number    {
    type:number
    html: <span title="ttttttt">{{rendered_value}}</span> ;;
  }

  dimension: input_parent_unique_id__dimension {
    hidden:yes
    sql:;;
}
dimension: input_child_unique_id__dimension {
  hidden:yes
  sql:;;
}
}
