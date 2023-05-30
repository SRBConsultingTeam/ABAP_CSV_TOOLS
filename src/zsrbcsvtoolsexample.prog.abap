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
REPORT zsrbcsvtoolsexample.

SELECTION-SCREEN BEGIN OF BLOCK b10 WITH FRAME TITLE TEXT-010.
  PARAMETERS: p_tab RADIOBUTTON GROUP rbg DEFAULT 'X'.
  PARAMETERS: p_json RADIOBUTTON GROUP rbg.
  PARAMETERS: p_json2 RADIOBUTTON GROUP rbg .
SELECTION-SCREEN END OF BLOCK b10.


CLASS att_mapper DEFINITION.
  PUBLIC SECTION.
    INTERFACES: zif_srb_csv_parser_json_attmap.
ENDCLASS.

CLASS att_mapper IMPLEMENTATION.
  METHOD zif_srb_csv_parser_json_attmap~get_json_attribute.
    json_attribute = to_mixed( val  = csv_header
                               sep  = | |
                               case = 'U'
                               min  = 1 ).
  ENDMETHOD.
ENDCLASS.

CLASS csv_config DEFINITION.
  PUBLIC SECTION.
    INTERFACES: zif_srb_csv_parser_config.
ENDCLASS.

CLASS csv_config IMPLEMENTATION.
  METHOD zif_srb_csv_parser_config~is_char_field_delimiter.
    is_delimiter = xsdbool( char = |'| ).
  ENDMETHOD.

  METHOD zif_srb_csv_parser_config~is_char_field_separator.
    is_separator = xsdbool( char = |;| ).
  ENDMETHOD.

  METHOD zif_srb_csv_parser_config~is_char_line_separator.
    is_separator = xsdbool( char = |\r| OR char = |\n| ).
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  DATA json TYPE string.
  DATA csv_to_json_converter TYPE REF TO zcl_srb_csv_to_json.

  DATA(csv) = |date,gross_value,currency code\n10.03.2023,"27,33",eur\n11.02.2012,"33,33",eur\n11.03.2023,"3,33",usd|.

  CASE abap_true.
    WHEN p_tab.
      DATA(csv_to_table_converter) = NEW zcl_srb_csv_to_stringtabtab( ).
      csv_to_table_converter->set_parser( NEW zcl_srb_csv_parser( ) ).

      DATA(csv_table_data) = csv_to_table_converter->parse( csv ).

      cl_demo_output=>display_data( csv_table_data ).


    WHEN p_json.
      csv_to_json_converter = NEW zcl_srb_csv_to_json( ).
      csv_to_json_converter->set_parser( NEW zcl_srb_csv_parser( ) ).

      json = csv_to_json_converter->get_json( csv ).

      cl_demo_output=>display_json( json ).


    WHEN p_json2.
      csv = |date;gross value;currency code\n10.03.2023;'27,33';eur\n11.02.2012;'33,33';eur\n11.03.2023;'3,33';usd|.

      csv_to_json_converter = NEW zcl_srb_csv_to_json( ).
      csv_to_json_converter->set_parser( NEW zcl_srb_csv_parser( configuration = NEW csv_config( ) ) ).

      csv_to_json_converter->set_attribute_mapper( NEW att_mapper( ) ).
      csv_to_json_converter->set_csv_output_option( zcl_srb_csv_to_json=>csv_output_options-compressed ).

      json = csv_to_json_converter->get_json( csv ).

      cl_demo_output=>display( json ).


  ENDCASE.
