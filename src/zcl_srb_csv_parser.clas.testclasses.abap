*"* use this source file for your ABAP unit test classes
CLASS ltcl_parser_values_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    INTERFACES zif_srb_csv_parser_ev_handl.

  PRIVATE SECTION.
    METHODS:
      simple_value FOR TESTING RAISING cx_static_check.

    METHODS:
      simple_value_with_crlf FOR TESTING RAISING cx_static_check.

    METHODS:
      simple_quoted_value FOR TESTING RAISING cx_static_check.

    METHODS:
      simple_quoted_value_with_crlf FOR TESTING RAISING cx_static_check.

    METHODS:
      complex_quoted_value FOR TESTING RAISING cx_static_check.

    METHODS init.

    DATA field_complete_count TYPE int4 VALUE 0.
    DATA row_complete_count TYPE int4 VALUE 0.
    DATA retrieved_value TYPE string.
ENDCLASS.


CLASS ltcl_parser_values_test IMPLEMENTATION.

  METHOD init.
    field_complete_count = 0.
    row_complete_count = 0.
    CLEAR retrieved_value.
  ENDMETHOD.

  METHOD zif_srb_csv_parser_ev_handl~handle_field_complete.
    field_complete_count = field_complete_count + 1.

    retrieved_value = fieldvalue.
  ENDMETHOD.

  METHOD zif_srb_csv_parser_ev_handl~handle_row_complete.
    row_complete_count = row_complete_count + 1.
  ENDMETHOD.

  METHOD simple_value.
    init( ).

    DATA(parser) = NEW zcl_srb_csv_parser( me ).

    parser->parse( |SiMpLeVaLuE| ).

    cl_abap_unit_assert=>assert_equals(
      act = retrieved_value
      exp = |SiMpLeVaLuE|
    ).

    cl_abap_unit_assert=>assert_equals(
      act = field_complete_count
      exp = 1
    ).

    cl_abap_unit_assert=>assert_equals(
      act = row_complete_count
      exp = 1
    ).

  ENDMETHOD.

  METHOD simple_value_with_crlf.
    init( ).

    DATA(parser) = NEW zcl_srb_csv_parser( me ).

    parser->parse( |SiMpLeVaLuE\r\n| ).

    cl_abap_unit_assert=>assert_equals(
      act = retrieved_value
      exp = |SiMpLeVaLuE|
    ).

    cl_abap_unit_assert=>assert_equals(
      act = field_complete_count
      exp = 1
    ).

    cl_abap_unit_assert=>assert_equals(
      act = row_complete_count
      exp = 1
    ).

  ENDMETHOD.

  METHOD simple_quoted_value.
    init( ).

    DATA(parser) = NEW zcl_srb_csv_parser( me ).

    parser->parse( |"SiMpLeVaLuE"| ).

    cl_abap_unit_assert=>assert_equals(
      act = retrieved_value
      exp = |SiMpLeVaLuE|
    ).

    cl_abap_unit_assert=>assert_equals(
      act = field_complete_count
      exp = 1
    ).

    cl_abap_unit_assert=>assert_equals(
      act = row_complete_count
      exp = 1
    ).
  ENDMETHOD.

  METHOD simple_quoted_value_with_crlf.
    init( ).

    DATA(parser) = NEW zcl_srb_csv_parser( me ).

    parser->parse( |"SiMpLeVaLuE"\r\n| ).

    cl_abap_unit_assert=>assert_equals(
      act = retrieved_value
      exp = |SiMpLeVaLuE|
    ).

    cl_abap_unit_assert=>assert_equals(
      act = field_complete_count
      exp = 1
    ).

    cl_abap_unit_assert=>assert_equals(
      act = row_complete_count
      exp = 1
    ).
  ENDMETHOD.

  METHOD complex_quoted_value.
    init( ).

    DATA(parser) = NEW zcl_srb_csv_parser( me ).

    parser->parse( |"This ""is a quoted"" value"\r\n| ).

    cl_abap_unit_assert=>assert_equals(
      act = retrieved_value
      exp = |This "is a quoted" value|
    ).

    cl_abap_unit_assert=>assert_equals(
      act = field_complete_count
      exp = 1
    ).

    cl_abap_unit_assert=>assert_equals(
      act = row_complete_count
      exp = 1
    ).
  ENDMETHOD.

ENDCLASS.



CLASS ltcl_parser_lines_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    INTERFACES zif_srb_csv_parser_ev_handl.

  PRIVATE SECTION.
    METHODS:
      simple_line FOR TESTING RAISING cx_static_check.

    METHODS:
      simple_line_with_space FOR TESTING RAISING cx_static_check.

    methods:
      simple_line_with_empty_fields for TESTING RAISING cx_static_check.

    METHODS:
      quoted_line FOR TESTING RAISING cx_static_check.

    METHODS:
      quoted_line_with_linebreaks FOR TESTING RAISING cx_static_check.

    METHODS init.

    DATA field_complete_count TYPE int4 VALUE 0.
    DATA row_complete_count TYPE int4 VALUE 0.
    DATA retrieved_values TYPE string_table.
ENDCLASS.


CLASS ltcl_parser_lines_test IMPLEMENTATION.

  METHOD init.
    field_complete_count = 0.
    row_complete_count = 0.
    CLEAR retrieved_values.
  ENDMETHOD.

  METHOD zif_srb_csv_parser_ev_handl~handle_field_complete.
    field_complete_count = field_complete_count + 1.

    APPEND fieldvalue TO retrieved_values.
  ENDMETHOD.

  METHOD zif_srb_csv_parser_ev_handl~handle_row_complete.
    row_complete_count = row_complete_count + 1.
  ENDMETHOD.

  METHOD simple_line.
    init( ).

    DATA(parser) = NEW zcl_srb_csv_parser( me ).

    parser->parse( |This,is,a,separated,line\r\n| ).

    cl_abap_unit_assert=>assert_equals(
      act = retrieved_values
      exp = VALUE string_table( ( |This| ) ( |is| ) ( |a| ) ( |separated| ) ( |line| ) )
    ).

    cl_abap_unit_assert=>assert_equals(
      act = field_complete_count
      exp = 5
    ).

    cl_abap_unit_assert=>assert_equals(
      act = row_complete_count
      exp = 1
    ).
  ENDMETHOD.

  METHOD simple_line_with_space.
    init( ).

    DATA(parser) = NEW zcl_srb_csv_parser( me ).

    parser->parse( | This,is , a,separated , line\r\n| ).

    cl_abap_unit_assert=>assert_equals(
      act = retrieved_values
      exp = VALUE string_table( ( |This| ) ( |is | ) ( |a| ) ( |separated | ) ( |line| ) )
    ).

    cl_abap_unit_assert=>assert_equals(
      act = field_complete_count
      exp = 5
    ).

    cl_abap_unit_assert=>assert_equals(
      act = row_complete_count
      exp = 1
    ).
  ENDMETHOD.

  METHOD simple_line_with_empty_fields.
    init( ).

    DATA(parser) = NEW zcl_srb_csv_parser( me ).

    parser->parse( | This,,,,contians empty lines\r\n| ).

    cl_abap_unit_assert=>assert_equals(
      act = retrieved_values
      exp = VALUE string_table( ( |This| ) ( || ) ( || ) ( || ) ( |contians empty lines| ) )
    ).

    cl_abap_unit_assert=>assert_equals(
      act = field_complete_count
      exp = 5
    ).

    cl_abap_unit_assert=>assert_equals(
      act = row_complete_count
      exp = 1
    ).
  ENDMETHOD.


  METHOD quoted_line.
    init( ).

    DATA(parser) = NEW zcl_srb_csv_parser( me ).

    parser->parse( |"This","is","a","separated,line"\r\n| ).

    cl_abap_unit_assert=>assert_equals(
      act = retrieved_values
      exp = VALUE string_table( ( |This| ) ( |is| ) ( |a| ) ( |separated,line| ) )
    ).

    cl_abap_unit_assert=>assert_equals(
      act = field_complete_count
      exp = 4
    ).

    cl_abap_unit_assert=>assert_equals(
      act = row_complete_count
      exp = 1
    ).
  ENDMETHOD.

  METHOD quoted_line_with_linebreaks.
    init( ).

    DATA(parser) = NEW zcl_srb_csv_parser( me ).

    parser->parse( |"Find","the\r\n","new\nline"| ).

    cl_abap_unit_assert=>assert_equals(
      act = retrieved_values
      exp = VALUE string_table( ( |Find| ) ( |the\r\n| ) ( |new\nline| ) )
    ).

    cl_abap_unit_assert=>assert_equals(
      act = field_complete_count
      exp = 3
    ).

    cl_abap_unit_assert=>assert_equals(
      act = row_complete_count
      exp = 1
    ).
  ENDMETHOD.

ENDCLASS.



CLASS ltcl_parser_mlines_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    INTERFACES zif_srb_csv_parser_ev_handl.

  PRIVATE SECTION.
    METHODS:
      simple_line FOR TESTING RAISING cx_static_check.

    METHODS:
      multi_line FOR TESTING RAISING cx_static_check.


    METHODS init.

    DATA field_complete_count TYPE int4 VALUE 0.
    DATA row_complete_count TYPE int4 VALUE 0.
    DATA retrieved_values TYPE string_table.
ENDCLASS.


CLASS ltcl_parser_mlines_test IMPLEMENTATION.

  METHOD init.
    field_complete_count = 0.
    row_complete_count = 0.
    CLEAR retrieved_values.
  ENDMETHOD.

  METHOD zif_srb_csv_parser_ev_handl~handle_field_complete.
    field_complete_count = field_complete_count + 1.

    APPEND fieldvalue TO retrieved_values.
  ENDMETHOD.

  METHOD zif_srb_csv_parser_ev_handl~handle_row_complete.
    row_complete_count = row_complete_count + 1.
  ENDMETHOD.

  METHOD simple_line.
    init( ).

    DATA(parser) = NEW zcl_srb_csv_parser( me ).

    parser->parse( |This,is,the,first,line\r\nThis,is,the,second,line| ).

    cl_abap_unit_assert=>assert_equals(
      act = retrieved_values
      exp = VALUE string_table( ( |This| ) ( |is| ) ( |the| ) ( |first| ) ( |line| )
                                ( |This| ) ( |is| ) ( |the| ) ( |second| ) ( |line| ) )
    ).

    cl_abap_unit_assert=>assert_equals(
      act = field_complete_count
      exp = 10
    ).

    cl_abap_unit_assert=>assert_equals(
      act = row_complete_count
      exp = 2
    ).
  ENDMETHOD.

  METHOD multi_line.
    init( ).

    DATA(parser) = NEW zcl_srb_csv_parser( me ).

    parser->parse( |"Key","Value","comment"\n"K1",,\n"K2",,\n| ).

    cl_abap_unit_assert=>assert_equals(
      act = retrieved_values
      exp = VALUE string_table( ( |Key| ) ( |Value| ) ( |comment| )
                                ( |K1| ) ( || ) ( || )
                                ( |K2| ) ( || ) ( || )  )
    ).

    cl_abap_unit_assert=>assert_equals(
      act = field_complete_count
      exp = 9
    ).

    cl_abap_unit_assert=>assert_equals(
      act = row_complete_count
      exp = 3
    ).
  ENDMETHOD.

ENDCLASS.
