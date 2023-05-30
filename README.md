# ABAP CSV TOOLS
This repository contains a lightweight but flexible framework to parse csv files in ABAP.

## Motivation
ABAP provides some different function modules or classes to import csv files, but no one supports all the following features:

* Support for different field separators
* Support for different field delimiters
* Support for escaped delimiters used in field values (e.g. `"This ""is a quoted"" value"`)
* Support for line breaks in delimited field values (e.g. `"This value \n contains a new line"`)
* Identify the column by header title instead of position
* Import column value without a priori knowledge of the datatype
* Transform or convert values during import
* Support for events

## Examples
See report [`zsrbcsvtoolsexample`](src/zsrbcsvtoolsexample.prog.abap) for more examples.

### Convert a csv file to a `STRING_TABLE`
```abap
DATA(csv) = |date,gross_value,currency code\n10.03.2023,"27,33",eur\n11.02.2012,"33,33",eur\n11.03.2023,"3,33",usd|.

DATA(csv_to_table_converter) = NEW zcl_srb_csv_to_stringtabtab( ).
csv_to_table_converter->set_parser( NEW zcl_srb_csv_parser( ) ).
DATA(csv_table_data) = csv_to_table_converter->parse( csv ).

cl_demo_output=>display_data( csv_table_data ).
```

### Using different separators an delimiters
Can be done if a new confituration class is created which implements interface `zif_srb_csv_parser_config`:

```abap
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
```

Pass the configuration object to the parser object:
```abap
csv_to_table_converter->set_parser( NEW zcl_srb_csv_parser( configuration = NEW csv_config( ) ) ).
```

### Convert a csv file to json
Why? Since the class `/ui2/cl_json` provides powerful json deserialization the idea was to transform csv to json in order to use the existing code.

```abap
DATA(csv) = |date,gross_value,currency code\n10.03.2023,"27,33",eur\n11.02.2012,"33,33",eur\n11.03.2023,"3,33",usd|.

csv_to_json_converter = NEW zcl_srb_csv_to_json( ).
csv_to_json_converter->set_parser( NEW zcl_srb_csv_parser( ) ).
json = csv_to_json_converter->get_json( csv ).

cl_demo_output=>display_json( json ).
```

## Authors
* [Andreas Ferdinand Kasper](https://github.com/AndreasFerdinand) - initial code base - [SRB Consulting Team GmbH](https://www.srb.at)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
