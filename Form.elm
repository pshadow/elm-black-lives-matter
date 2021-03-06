module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App
import Zipcode


type alias Model =
    { zipcode : Maybe String
    , zipcodeEntry : String
    , departmentType : Maybe DepartmentType
    }


type DepartmentType
    = PoliceDepartment
    | SherriffDepartment


initialModel : Model
initialModel =
    { zipcode = Nothing
    , zipcodeEntry = ""
    , departmentType = Nothing
    }


debuggingModel : Model
debuggingModel =
    { initialModel
        | zipcode = Just "12345"
        , departmentType = Just PoliceDepartment
    }



-- subscriptions :


type Msg
    = ZipcodeChanged String
    | SubmitZipcode
    | ChooseDepartmentType DepartmentType
    | PoliceDepartmentNameChanged String
    | PoliceChiefNameChanged String
    | PoliceWebsiteChanged String
    | PoliceTwitterChanged String
    | SubmitPoliceDepartment


update : Msg -> Model -> Model
update msg model =
    case Debug.log "update" msg of
        ZipcodeChanged newEntry ->
            { model | zipcodeEntry = newEntry }

        SubmitZipcode ->
            if Zipcode.isValid model.zipcodeEntry then
                { model | zipcode = Just model.zipcodeEntry }
            else
                model

        ChooseDepartmentType departmentType ->
            { model | departmentType = Just departmentType }

        _ ->
            model


type alias InputFieldModel msg =
    { id : String
    , label : String
    , invalid : Bool
    , msg : String -> msg
    }


inputField : InputFieldModel Msg -> Html Msg
inputField { id, label, invalid, msg } =
    div [ class "pure-control-group" ]
        [ Html.label [ for id ] [ text label ]
        , input
            [ Html.Attributes.id id
            , type' "text"
            , classList
                [ ( "input-invalid", invalid ) ]
            , onInput msg
            ]
            []
        ]


type alias InputFormModel msg =
    { onSubmit : Msg
    , fields : List (InputFieldModel msg)
    , disabled : Bool
    }


inputForm : InputFormModel Msg -> Html Msg
inputForm { onSubmit, fields, disabled } =
    let
        submitButton =
            [ div [ class "pure-controls" ]
                [ button
                    [ classList
                        [ ( "pure-button", True )
                        , ( "pure-button-primary", True )
                        , ( "pure-button-disabled", disabled )
                        ]
                    , type' "submit"
                    , Html.Attributes.disabled disabled
                    ]
                    [ text "Continue" ]
                ]
            ]
    in
        Html.form
            [ class "pure-form pure-form-aligned"
            , Html.Events.onSubmit onSubmit
            , Html.Attributes.disabled disabled
            ]
            [ fieldset [] (List.map inputField fields ++ submitButton)
            ]


zipcodeForm : String -> Html Msg
zipcodeForm zipcodeEntry =
    let
        zipcodeIsInvalid =
            not (Zipcode.isValid zipcodeEntry)
    in
        inputForm
            { onSubmit = SubmitZipcode
            , disabled = zipcodeIsInvalid
            , fields =
                [ { id = "zipcode"
                  , label = "Zipcode"
                  , invalid = zipcodeIsInvalid
                  , msg = ZipcodeChanged
                  }
                ]
            }


departmentTypeForm : Html Msg
departmentTypeForm =
    Html.div [ class "pure-form" ]
        [ p [] [ text "Are you reporting information about a police department or a sheriff department?" ]
        , p []
            [ button
                [ class "pure-button"
                , onClick (ChooseDepartmentType PoliceDepartment)
                ]
                [ text "Police Department" ]
            ]
        , p []
            [ button
                [ class "pure-button"
                , onClick (ChooseDepartmentType SherriffDepartment)
                ]
                [ text "Sheriff Department" ]
            ]
        ]


view : Model -> Html Msg
view model =
    case model.zipcode of
        Nothing ->
            zipcodeForm model.zipcodeEntry

        Just zipcode ->
            case model.departmentType of
                Nothing ->
                    departmentTypeForm

                Just PoliceDepartment ->
                    inputForm
                        { disabled = True
                        , onSubmit = SubmitPoliceDepartment
                        , fields =
                            [ { id = "departmentName"
                              , label = "Name of Police Department"
                              , invalid = False
                              , msg = PoliceDepartmentNameChanged
                              }
                            , { id = "policeChiefName"
                              , label = "Name of Current Police Chief"
                              , invalid = False
                              , msg = PoliceChiefNameChanged
                              }
                            , { id = "policeWebsite"
                              , label = "Website of Police Department"
                              , invalid = False
                              , msg = PoliceWebsiteChanged
                              }
                            , { id = "policeTwitter"
                              , label = "Twitter of Police Department"
                              , invalid = False
                              , msg = PoliceTwitterChanged
                              }
                            ]
                        }

                Just SherriffDepartment ->
                    text "TODO: show Sheriff Department form"


main : Program Never
main =
    Html.App.beginnerProgram
        { model = initialModel
        , update = update
        , view = view
        }
