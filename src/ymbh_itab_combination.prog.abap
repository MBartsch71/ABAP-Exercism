REPORT ymbh_itab_combination.


CLASS lcl_itab_combination DEFINITION.

  PUBLIC SECTION.

    TYPES: BEGIN OF alphatab_type,
             cola TYPE string,
             colb TYPE string,
             colc TYPE string,
           END OF alphatab_type.
    TYPES alphas TYPE STANDARD TABLE OF alphatab_type.

    TYPES: BEGIN OF numtab_type,
             col1 TYPE string,
             col2 TYPE string,
             col3 TYPE string,
           END OF numtab_type.
    TYPES nums TYPE STANDARD TABLE OF numtab_type.

    TYPES: BEGIN OF combined_data_type,
             colx TYPE string,
             coly TYPE string,
             colz TYPE string,
           END OF combined_data_type.
    TYPES combined_data TYPE STANDARD TABLE OF combined_data_type WITH EMPTY KEY.

    METHODS perform_combination
      IMPORTING
        alphas               TYPE alphas
        nums                 TYPE nums
      RETURNING
        VALUE(combined_data) TYPE combined_data.

ENDCLASS.

CLASS lcl_itab_combination IMPLEMENTATION.

  METHOD perform_combination.
    DATA(table_lines) = lines( nums ).
    IF table_lines = 0.
      RETURN.
    ENDIF.
    combined_data = VALUE #( FOR i = 1 THEN i + 1 UNTIL i > table_lines
                                ( colx = alphas[ i ]-cola && nums[ i ]-col1
                                  coly = alphas[ i ]-colb && nums[ i ]-col2
                                  colz = alphas[ i ]-colc && nums[ i ]-col3 ) ).
  ENDMETHOD.

ENDCLASS.
CLASS ltcl_itab_combination DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    DATA cut TYPE REF TO lcl_itab_combination.
    METHODS setup.
    METHODS test_empty_input FOR TESTING RAISING cx_static_check.
    METHODS test_single_row FOR TESTING RAISING cx_static_check.
    METHODS test_combination FOR TESTING RAISING cx_static_check.
ENDCLASS.
CLASS ltcl_itab_combination IMPLEMENTATION.

  METHOD setup.
    cut = NEW lcl_itab_combination( ).
  ENDMETHOD.

  METHOD test_empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = cut->perform_combination( alphas = VALUE #( )
                                      nums = VALUE #( ) )
      exp = VALUE lcl_itab_combination=>combined_data( ) ).
  ENDMETHOD.

  METHOD test_single_row.

    cl_abap_unit_assert=>assert_equals(
      act = cut->perform_combination(
                     alphas  = VALUE #( ( cola = 'A' colb = 'B' colc = 'C' ) )
                     nums    = VALUE #( ( col1 = '1' col2 = '2' col3 = '3' ) ) )
      exp = VALUE lcl_itab_combination=>combined_data( ( colx = 'A1' coly = 'B2' colz = 'C3' ) ) ).

  ENDMETHOD.

  METHOD test_combination.

    cl_abap_unit_assert=>assert_equals(
      act = cut->perform_combination(
        alphas      = VALUE #( ( cola = 'A' colb = 'B' colc = 'C' )
                          ( cola = 'D' colb = 'E' colc = 'F' )
                          ( cola = 'G' colb = 'H' colc = 'I' )
                        )
        nums        = VALUE #( ( col1 = '1' col2 = '2' col3 = '3' )
                          ( col1 = '4' col2 = '5' col3 = '6' )
                          ( col1 = '7' col2 = '8' col3 = '9' )
                        )
             )
       exp = VALUE lcl_itab_combination=>combined_data( ( colx = 'A1' coly = 'B2' colz = 'C3' )
                          ( colx = 'D4' coly = 'E5' colz = 'F6' )
                          ( colx = 'G7' coly = 'H8' colz = 'I9' )
             ) ).

  ENDMETHOD.

ENDCLASS.
