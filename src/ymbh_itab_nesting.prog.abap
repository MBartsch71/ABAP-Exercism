REPORT ymbh_itab_nesting.

CLASS lcl_itab_nesting DEFINITION.

  PUBLIC SECTION.

    TYPES: BEGIN OF artists_type,
             artist_id   TYPE string,
             artist_name TYPE string,
           END OF artists_type.
    TYPES artists TYPE STANDARD TABLE OF artists_type WITH KEY artist_id.
    TYPES: BEGIN OF albums_type,
             artist_id  TYPE string,
             album_id   TYPE string,
             album_name TYPE string,
           END OF albums_type.
    TYPES albums TYPE STANDARD TABLE OF albums_type WITH KEY artist_id album_id.
    TYPES: BEGIN OF songs_type,
             artist_id TYPE string,
             album_id  TYPE string,
             song_id   TYPE string,
             song_name TYPE string,
           END OF songs_type.
    TYPES songs TYPE STANDARD TABLE OF songs_type WITH KEY artist_id album_id song_id.


    TYPES: BEGIN OF song_nested_type,
             song_id   TYPE string,
             song_name TYPE string,
           END OF song_nested_type.
    TYPES: BEGIN OF album_song_nested_type,
             album_id   TYPE string,
             album_name TYPE string,
             songs      TYPE STANDARD TABLE OF song_nested_type WITH KEY song_id,
           END OF album_song_nested_type.
    TYPES: BEGIN OF artist_album_nested_type,
             artist_id   TYPE string,
             artist_name TYPE string,
             albums      TYPE STANDARD TABLE OF album_song_nested_type WITH KEY album_id,
           END OF artist_album_nested_type.
    TYPES nested_data TYPE STANDARD TABLE OF artist_album_nested_type WITH KEY artist_id.

    METHODS perform_nesting
      IMPORTING
        artists            TYPE artists
        albums             TYPE albums
        songs              TYPE songs
      RETURNING
        VALUE(nested_data) TYPE nested_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS lcl_itab_nesting IMPLEMENTATION.

  METHOD perform_nesting.
    nested_data = VALUE #( FOR artist IN artists
                            ( artist_id   = artist-artist_id
                              artist_name = artist-artist_name
                              albums      = VALUE #( FOR album IN albums WHERE ( artist_id = artist-artist_id )
                                                        ( album_id   = album-album_id
                                                          album_name = album-album_name
                                                          songs      = VALUE #( FOR song IN songs WHERE ( artist_id = artist-artist_id AND
                                                                                                          album_id = album-album_id )
                                                                         ( song_id   = song-song_id
                                                                           song_name = song-song_name ) ) ) ) ) ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_itab_nesting DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    DATA cut TYPE REF TO lcl_itab_nesting.
    METHODS setup.
    METHODS test_empty_input FOR TESTING RAISING cx_static_check.
    METHODS test_single_artist FOR TESTING RAISING cx_static_check.
    METHODS test_single_artist_no_album FOR TESTING RAISING cx_static_check.
    METHODS test_nesting FOR TESTING RAISING cx_static_check.
ENDCLASS.
CLASS ltcl_itab_nesting IMPLEMENTATION.

  METHOD setup.
    cut = NEW lcl_itab_nesting( ).
  ENDMETHOD.

  METHOD test_empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = cut->perform_nesting( artists = VALUE #( )
                                  albums = VALUE #( )
                                  songs = VALUE #( ) )
      exp = VALUE lcl_itab_nesting=>nested_data( ) ).
  ENDMETHOD.

  METHOD test_single_artist.
    cl_abap_unit_assert=>assert_equals(
      act = cut->perform_nesting(
        artists     = VALUE #( ( artist_id = '1' artist_name = 'Godsmack' ) )
        albums      = VALUE #( ( artist_id = '1' album_id = '1' album_name = 'Faceless' ) )
        songs       = VALUE #( ( artist_id = '1' album_id = '1' song_id = '1' song_name = 'Straight Out Of Line' ) ) )
      exp = VALUE lcl_itab_nesting=>nested_data( ( artist_id = '1' artist_name = 'Godsmack'
                           albums = VALUE #( ( album_id = '1' album_name = 'Faceless'
                                               songs = VALUE #( ( song_id = '1' song_name = 'Straight Out Of Line' ) )
                                             ) )
                                   ) ) ).
  ENDMETHOD.

  METHOD test_single_artist_no_album.
    cl_abap_unit_assert=>assert_equals(
      act = cut->perform_nesting(
        artists     = VALUE #( ( artist_id = '1' artist_name = 'Godsmack' ) )
        albums      = VALUE #( )
        songs       = VALUE #( ) )
      exp = VALUE lcl_itab_nesting=>nested_data( ( artist_id = '1' artist_name = 'Godsmack'
                                        albums = VALUE #( ) ) ) ).
  ENDMETHOD.


  METHOD test_nesting.

    cl_abap_unit_assert=>assert_equals(
      act = cut->perform_nesting(
        artists     = VALUE #( ( artist_id = '1' artist_name = 'Godsmack' )
                                ( artist_id = '2' artist_name = 'Shinedown' ) )
        albums      = VALUE #( ( artist_id = '1' album_id = '1' album_name = 'Faceless' )
                                ( artist_id = '1' album_id = '2' album_name = 'When Lengends Rise' )
                                ( artist_id = '2' album_id = '1' album_name = 'The Sound of Madness' )
                                ( artist_id = '2' album_id = '2' album_name = 'Planet Zero' )
          )
        songs       = VALUE #( ( artist_id = '1' album_id = '1' song_id = '1' song_name = 'Straight Out Of Line' )
                                ( artist_id = '1' album_id = '1' song_id = '2' song_name = 'Changes' )
                                ( artist_id = '1' album_id = '2' song_id = '1' song_name = 'Bullet Proof' )
                                ( artist_id = '1' album_id = '2' song_id = '2' song_name = 'Under Your Scars' )
                                ( artist_id = '2' album_id = '1' song_id = '1' song_name = 'Second Chance' )
                                ( artist_id = '2' album_id = '1' song_id = '2' song_name = 'Breaking Inside' )
                                ( artist_id = '2' album_id = '2' song_id = '1' song_name = 'Dysfunctional You' )
                                ( artist_id = '2' album_id = '2' song_id = '2' song_name = 'Daylight' )
                                )
             )
       exp = VALUE lcl_itab_nesting=>nested_data(
                 ( artist_id = '1' artist_name = 'Godsmack'
                    albums      = VALUE #( ( album_id = '1' album_name = 'Faceless'
                                         songs       = VALUE #( ( song_id = '1' song_name = 'Straight Out Of Line' )
                                                                ( song_id = '2' song_name = 'Changes' )
                                                                ) )
                                           ( album_id = '2' album_name = 'When Lengends Rise'
                                         songs       = VALUE #( ( song_id = '1' song_name = 'Bullet Proof' )
                                                                ( song_id = '2' song_name = 'Under Your Scars' )
                                                                ) )
                                        ) )
                 ( artist_id = '2' artist_name = 'Shinedown'
                    albums      = VALUE #( ( album_id = '1' album_name = 'The Sound of Madness'
                                          songs       = VALUE #( ( song_id = '1' song_name = 'Second Chance' )
                                                                 ( song_id = '2' song_name = 'Breaking Inside' )
                                                                ) )
                                           ( album_id = '2' album_name = 'Planet Zero'
                                          songs       = VALUE #( ( song_id = '1' song_name = 'Dysfunctional You' )
                                                                 ( song_id = '2' song_name = 'Daylight' )
                                                                ) )
                                        ) )
                                   ) ).

  ENDMETHOD.

ENDCLASS.
