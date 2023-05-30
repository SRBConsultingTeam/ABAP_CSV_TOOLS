*******************************************************************************************************************************
** The MIT License (MIT)
**
** Copyright 2023 SRB Consulting Team GmbH
**
** Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
** files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
** modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
** Software is furnished to do so, subject to the following conditions:
**
** The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
** Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
** WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
** COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
** ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*******************************************************************************************************************************

CLASS zcl_srb_csv_to_json DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_srb_csv_parser_ev_handl.
    INTERFACES zif_srb_csv_parser_json_attmap.

    TYPES: csv_output_option_t TYPE int1.
    CONSTANTS: BEGIN OF csv_output_options,
                 compressed    TYPE csv_output_option_t VALUE 0,
                 prettyprint TYPE csv_output_option_t VALUE 1,
               END OF csv_output_options.

    TYPES: BEGIN OF header_attribute_pair_t,
             csv_header     TYPE string,
             json_attribute TYPE string,
           END OF header_attribute_pair_t.

    TYPES: header_attribute_map_tt TYPE STANDARD TABLE OF header_attribute_pair_t WITH EMPTY KEY.

    METHODS set_parser
      IMPORTING parser TYPE REF TO zcl_srb_csv_parser.

    METHODS set_attribute_mapper
      IMPORTING attribute_mapper TYPE REF TO zif_srb_csv_parser_json_attmap.

    METHODS get_json
      IMPORTING csv         TYPE string
      RETURNING VALUE(json) TYPE string.

    METHODS: constructor,
      set_csv_output_option IMPORTING csv_output_option TYPE csv_output_option_t.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA parser TYPE REF TO zcl_srb_csv_parser.
    DATA attribute_mapper TYPE REF TO zif_srb_csv_parser_json_attmap.
    DATA header_line_retrieved TYPE abap_bool VALUE abap_false.
    DATA csv_output_option TYPE csv_output_option_t VALUE csv_output_options-prettyprint.
    DATA header_attribute_map TYPE header_attribute_map_tt.
    DATA current_values TYPE string_table.
    DATA json_elements TYPE string_table.
    DATA json TYPE string.

    METHODS get_line_break
      RETURNING VALUE(line_break) TYPE string.

    METHODS get_indent
      RETURNING VALUE(indent) TYPE string.

    methods get_spacer
      RETURNING VALUE(spacer) type string.
ENDCLASS.


CLASS zcl_srb_csv_to_json IMPLEMENTATION.

  METHOD constructor.
    set_attribute_mapper( me ).
  ENDMETHOD.

  METHOD set_parser.
    me->parser = parser.
    me->parser->set_event_handler( me ).
  ENDMETHOD.

  METHOD set_attribute_mapper.
    me->attribute_mapper = attribute_mapper.
  ENDMETHOD.

  METHOD set_csv_output_option.
    me->csv_output_option = csv_output_option.
  ENDMETHOD.


  METHOD zif_srb_csv_parser_ev_handl~handle_field_complete.
    IF ( header_line_retrieved <> abap_true ).
      APPEND VALUE #( csv_header = fieldvalue
                      json_attribute = attribute_mapper->get_json_attribute(
                                         csv_header    = fieldvalue
                                         column_number = column_number
                                       ) ) TO header_attribute_map.
    ELSE.
      APPEND fieldvalue TO current_values.
    ENDIF.
  ENDMETHOD.

  METHOD zif_srb_csv_parser_ev_handl~handle_row_complete.
    IF ( header_line_retrieved <> abap_true ).
      header_line_retrieved = abap_true.
    ELSE.
      "Build JSON for CSV line
      DATA json_kvps TYPE string_table.

      LOOP AT header_attribute_map ASSIGNING FIELD-SYMBOL(<header>).

        DATA(current_value) = current_values[ sy-tabix ].

        APPEND |{ get_indent( ) }{ get_indent( ) }"{ <header>-json_attribute }"{ get_spacer( ) }:{ get_spacer( ) }"{ current_value }"| TO json_kvps.

      ENDLOOP.

      DATA(json_node) = concat_lines_of( table = json_kvps sep = |,{ get_line_break( ) }| ).
      json_node = get_indent( ) && '{' && get_line_break( ) && json_node && get_line_break( ) && get_indent( ) && '}'.

      APPEND json_node TO json_elements.

      CLEAR current_values.
    ENDIF.
  ENDMETHOD.

  METHOD get_json.
    parser->parse( csv ).

    json = concat_lines_of( table = json_elements sep = |,{ get_line_break( ) }| ).
    json = '[' && get_line_break( ) && json && get_line_break( ) &&  ']'.

  ENDMETHOD.

  METHOD zif_srb_csv_parser_json_attmap~get_json_attribute.
    json_attribute = csv_header.
  ENDMETHOD.

  METHOD get_line_break.
    line_break = COND #( WHEN csv_output_option = csv_output_options-compressed THEN || ELSE |\n| ).
  ENDMETHOD.

  METHOD get_indent.
    indent = COND #( WHEN csv_output_option = csv_output_options-compressed THEN || ELSE |  | ).
  ENDMETHOD.

  METHOD get_spacer.
    spacer = COND #( WHEN csv_output_option = csv_output_options-compressed THEN || ELSE | | ).
  ENDMETHOD.

ENDCLASS.
