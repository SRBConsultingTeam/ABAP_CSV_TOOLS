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

CLASS zcl_srb_csv_parser DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_srb_csv_parser_config.

    METHODS constructor
      IMPORTING event_handler TYPE REF TO zif_srb_csv_parser_ev_handl OPTIONAL
                configuration TYPE REF TO zif_srb_csv_parser_config OPTIONAL
                  PREFERRED PARAMETER event_handler.

    METHODS: parse
      IMPORTING csv TYPE string.

    METHODS: set_event_handler
      IMPORTING event_handler TYPE REF TO zif_srb_csv_parser_ev_handl.

    TYPES state TYPE int4.

    CONSTANTS: BEGIN OF states,
                 field_start         TYPE state VALUE 0,
                 unquoted_field      TYPE state VALUE 1,
                 quoted_field        TYPE state VALUE 2,
                 escape_or_field_end TYPE state VALUE 3,
               END OF states.
  PROTECTED SECTION.
    METHODS: handle_field_complete.
    METHODS: handle_line_complete.

  PRIVATE SECTION.
    DATA event_handler TYPE REF TO zif_srb_csv_parser_ev_handl.
    DATA configuration TYPE REF TO zif_srb_csv_parser_config.
    DATA current_field_value TYPE string.
    DATA current_state TYPE state.
    DATA current_row TYPE int4.
    DATA current_column TYPE int4.
ENDCLASS.



CLASS zcl_srb_csv_parser IMPLEMENTATION.

  METHOD constructor.
    current_row = 1.
    current_column = 1.
    current_field_value = ''.
    current_state = states-field_start.

    me->event_handler = event_handler.

    me->configuration = COND #( WHEN configuration IS BOUND THEN configuration ELSE me ).
  ENDMETHOD.


  METHOD parse.
    DATA last_char TYPE string.
    DATA current_char TYPE string.
    DATA(csv_length) = strlen( csv ).

    DO csv_length TIMES.
      last_char = current_char.
      current_char = substring( val = csv len = 1 off = sy-index - 1 ).

      CASE current_state.

        WHEN states-field_start.

          IF configuration->is_char_field_delimiter( current_char ).
            current_state = states-quoted_field.
          ELSEIF configuration->is_char_field_separator( current_char ).
            handle_field_complete( ).

          ELSEIF configuration->is_char_line_separator( current_char ).
            IF ( configuration->is_char_field_separator( last_char ) ).
              handle_field_complete( ).
              handle_line_complete( ).
            ENDIF.

          ELSEIF current_char = ` `.
            "nothing to do
          ELSE.
            current_field_value = current_field_value && current_char.

            current_state = states-unquoted_field.
          ENDIF.

        WHEN states-unquoted_field.

          IF configuration->is_char_field_separator( current_char ).
            handle_field_complete( ).

            current_state = states-field_start.
          ELSEIF configuration->is_char_line_separator( current_char ).
            handle_field_complete( ).
            handle_line_complete( ).

            current_state = states-field_start.
          ELSE.
            current_field_value = current_field_value && current_char.
          ENDIF.

        WHEN states-quoted_field.

          IF configuration->is_char_field_delimiter( current_char ).
            current_state = states-escape_or_field_end.
          ELSE.
            current_field_value = current_field_value && current_char.
          ENDIF.

        WHEN states-escape_or_field_end.

          IF configuration->is_char_field_delimiter( current_char ).
            current_field_value = current_field_value && current_char.

            current_state = states-quoted_field.
          ELSEIF configuration->is_char_field_separator( current_char ).
            handle_field_complete( ).

            current_state = states-field_start.

          ELSEIF configuration->is_char_line_separator( current_char ).
            handle_field_complete( ).
            handle_line_complete( ).

            current_state = states-field_start.
          ELSEIF current_char = ` `.
            handle_field_complete( ).

            current_state = states-field_start.
          ELSE.
            "TODO EXCEPTION
          ENDIF.

      ENDCASE.


    ENDDO.

    last_char = current_char.

    IF ( current_state <> states-field_start OR ( current_state = states-field_start AND configuration->is_char_field_separator( last_char ) ) ).
      handle_field_complete( ).
      handle_line_complete( ).
    ENDIF.

  ENDMETHOD.


  METHOD zif_srb_csv_parser_config~is_char_field_separator.
    is_separator = xsdbool( char = ',' ).
  ENDMETHOD.

  METHOD zif_srb_csv_parser_config~is_char_line_separator.
    is_separator = xsdbool( char = |\r| OR char = |\n| ).
  ENDMETHOD.

  METHOD zif_srb_csv_parser_config~is_char_field_delimiter.
    is_delimiter = xsdbool( char = '"' ).
  ENDMETHOD.


  METHOD handle_field_complete.
    event_handler->handle_field_complete(
      fieldvalue    = current_field_value
      row_number    = current_row
      column_number = current_column
    ).

    current_field_value = ''.
    current_column = current_column + 1.
  ENDMETHOD.

  METHOD handle_line_complete.
    event_handler->handle_row_complete( current_row ).

    current_row = current_row + 1.
    current_column = 1.
  ENDMETHOD.

  METHOD set_event_handler.
    me->event_handler = event_handler.
  ENDMETHOD.

ENDCLASS.
