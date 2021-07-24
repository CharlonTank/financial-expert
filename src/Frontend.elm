module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html
import Html.Attributes as Attr
import Lamdera
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , message = "Welcome to Lamdera! You're looking at the auto-generated base implementation. Check out src/Frontend.elm to start coding!"
      , question = ""
      }
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Cmd.batch [ Nav.pushUrl model.key (Url.toString url) ]
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        TextChanged newQuestion ->
            ( { model | question = newQuestion }, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )


view : Model -> { title : String, body : List (Html.Html FrontendMsg) }
view model =
    { title = "AI Financial Expert"
    , body =
        [ layout [ width fill, height fill ]
            (Element.column
                [ Element.height Element.shrink
                , Element.width Element.fill
                , Element.paddingXY 192 192
                ]
                [ Element.column
                    [ Element.spacingXY 0 32
                    , Element.height Element.shrink
                    , Element.width Element.fill
                    ]
                    [ Element.paragraph
                        [ Font.center
                        , Font.bold
                        , Font.color (Element.rgba255 136 170 166 1)
                        , Font.size 36
                        , Element.height Element.shrink
                        , Element.width Element.fill
                        , Region.heading 1
                        ]
                        [ Element.text "Financial Expert AI" ]
                    , Element.paragraph
                        [ Font.center
                        , Font.bold
                        , Font.color (Element.rgba255 46 52 54 1)
                        , Font.size 24
                        , Element.height Element.shrink
                        , Element.width Element.fill
                        , Region.heading 2
                        ]
                        [ Element.text "Ask anything" ]
                    , Input.text
                        [ Element.centerY
                        , Element.centerX
                        , Element.spacingXY 0 4
                        , Element.height Element.shrink
                        , Element.width
                            (Element.fill
                                |> Element.maximum 1024
                                |> Element.minimum 256
                            )
                        , Element.paddingXY 8 8
                        , Border.rounded 2
                        , Border.color (Element.rgba255 186 189 182 1)
                        , Border.solid
                        , Border.widthXY 1 1
                        , Font.center
                        ]
                        { onChange = TextChanged
                        , text = model.question
                        , placeholder = Nothing
                        , label =
                            Input.labelAbove
                                [ Font.color (Element.rgba255 46 52 54 1) ]
                                (Element.text "")
                        }
                    , Element.column
                        [ Element.height Element.shrink
                        , Element.width Element.fill
                        ]
                        [ Element.paragraph
                            [ Element.centerY
                            , Element.centerX
                            , Font.center
                            , Element.spacingXY 0 4
                            , Element.height Element.shrink
                            , Element.width
                                (Element.fill
                                    |> Element.maximum 1024
                                    |> Element.minimum 256
                                )
                            ]
                            [ Element.text "Answer:" ]
                        ]
                    ]
                ]
            )
        ]
    }
