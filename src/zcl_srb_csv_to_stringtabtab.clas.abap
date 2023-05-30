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

CLASS zcl_srb_csv_to_stringtabtab DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: stringtable_table TYPE STANDARD TABLE OF string_table WITH EMPTY KEY.

    METHODS set_parser
      IMPORTING parser TYPE REF TO zcl_srb_csv_parser.

    METHODS parse
      IMPORTING csv               TYPE string
      RETURNING VALUE(parsed_csv) TYPE stringtable_table.

    INTERFACES zif_srb_csv_parser_ev_handl .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA parser TYPE REF TO zcl_srb_csv_parser.
    DATA current_line TYPE string_table.
    DATA parsed_csv TYPE stringtable_table.
ENDCLASS.



CLASS zcl_srb_csv_to_stringtabtab IMPLEMENTATION.

  METHOD zif_srb_csv_parser_ev_handl~handle_field_complete.
    APPEND fieldvalue TO current_line.
  ENDMETHOD.

  METHOD zif_srb_csv_parser_ev_handl~handle_row_complete.
    APPEND current_line TO parsed_csv.
    CLEAR current_line.
  ENDMETHOD.

  METHOD set_parser.
    me->parser = parser.
  ENDMETHOD.

  METHOD parse.
    parser = NEW zcl_srb_csv_parser( me ).

    parser->parse( csv ).

    parsed_csv = me->parsed_csv.
  ENDMETHOD.

ENDCLASS.
