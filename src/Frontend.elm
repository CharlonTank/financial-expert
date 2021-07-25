module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html
import Http exposing (Error(..))
import Lamdera
import Task
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
      , openAIResponse = Nothing
      , openAIState = Waiting
      , counter = 0
      , device = Nothing
      }
    , Cmd.batch [ Task.attempt ReceiveViewport <| Dom.getViewport, Lamdera.sendToBackend GetCounter ]
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

        ReceiveViewport (Ok viewport) ->
            ( { model | device = Just <| classifyDeviceFromViewport viewport }, Cmd.none )

        ReceiveViewport (Err _) ->
            ( model, Cmd.none )

        TextChanged newQuestion ->
            ( { model | question = newQuestion }, Cmd.none )

        SubmitQuestion ->
            ( { model | openAIState = Thinking }, Lamdera.sendToBackend <| ReceiveQuestion model.question )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        ReceiveOpenAIResponse (Ok openAIResponse) ->
            ( { model | openAIResponse = Just openAIResponse, openAIState = Waiting }, Cmd.none )

        ReceiveOpenAIResponse (Err error) ->
            ( { model | openAIState = Error error }, Cmd.none )

        TooMuchQuestions ->
            ( { model | openAIState = Saturated }, Cmd.none )

        ReceiveCounter counter ->
            ( { model | counter = counter }, Cmd.none )


view : Model -> { title : String, body : List (Html.Html FrontendMsg) }
view model =
    { title = "AI Financial Expert"
    , body =
        [ layout [ width fill, height fill ]
            (column
                [ height shrink
                , width fill
                , paddingXY 32 32
                ]
                [ column
                    [ spacingXY 0 32
                    , height shrink
                    , width fill
                    ]
                    [ el
                        [ Font.center
                        , Font.bold
                        , Font.color (rgba255 136 170 166 1)
                        , Font.size 36
                        , height shrink
                        , width fill
                        , Region.heading 1
                        ]
                      <|
                        text "Financial Expert AI"
                    , paragraph
                        [ Font.center
                        , Font.bold
                        , Font.color (rgba255 46 52 54 1)
                        , Font.size 24
                        , height shrink
                        , width fill
                        , Region.heading 2
                        ]
                        [ text <| "Ask me anything (" ++ String.fromInt model.counter ++ "/30)" ]
                    , Input.text
                        [ centerY
                        , centerX
                        , spacingXY 0 4
                        , height shrink
                        , width
                            (fill
                                |> maximum 1024
                                |> minimum 256
                            )
                        , paddingXY 8 8
                        , Border.rounded 2
                        , Border.color (rgba255 186 189 182 1)
                        , Border.solid
                        , Border.widthXY 1 1
                        , Font.center
                        ]
                        { onChange = TextChanged
                        , text = model.question
                        , placeholder = Nothing
                        , label =
                            Input.labelAbove
                                [ Font.color (rgba255 46 52 54 1) ]
                                (text "")
                        }
                    , Input.button
                        [ Background.color (rgba255 52 101 164 1)
                        , centerY
                        , centerX
                        , Font.center
                        , Font.color (rgba255 255 255 255 1)
                        , height shrink
                        , width shrink
                        , paddingXY 16 8
                        , Border.rounded 2
                        , Border.color (rgba255 52 101 164 1)
                        , Border.solid
                        , Border.widthXY 1 1
                        ]
                        { onPress =
                            if model.openAIState == Waiting then
                                Just SubmitQuestion

                            else
                                Nothing
                        , label = text "Submit question"
                        }
                    , column
                        [ height shrink
                        , width fill
                        ]
                        [ paragraph
                            [ centerY
                            , centerX
                            , spacingXY 0 4
                            , height shrink
                            , width
                                (fill
                                    |> maximum 1024
                                    |> minimum 256
                                )
                            ]
                            [ paragraph [] [ text "Answer: ", viewResponse model.openAIResponse model.openAIState ] ]
                        ]
                    ]
                ]
            )
        ]
    }


viewResponse : Maybe OpenAIResponse -> OpenAIState -> Element FrontendMsg
viewResponse openAIResponse_ openAIState =
    case openAIState of
        Thinking ->
            text "...sorry...but...I...need...time...to...think..."

        Saturated ->
            text "Every question answered costs money to Charles, please ask him to reload the backend so you can try"

        Error err ->
            text <| httpErrorToString err

        Waiting ->
            case openAIResponse_ of
                Nothing ->
                    none

                Just openAIResponse ->
                    text <| removeAPrompt <| Maybe.withDefault "" <| Maybe.map .text <| List.head openAIResponse.choices


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        BadUrl url ->
            "The only thing I can answer you is this bad url... " ++ url

        Timeout ->
            "I'm sorry, I think that I think too much... Timeout"

        NetworkError ->
            "I need internet to be able to answer you!"

        BadStatus status ->
            "The only thing I can answer you is this bad status number... " ++ String.fromInt status

        BadBody body ->
            "The only thing I can answer you is this bad body... " ++ body


removeAPrompt : String -> String
removeAPrompt =
    String.dropLeft 3


classifyDeviceFromViewport : Dom.Viewport -> Device
classifyDeviceFromViewport viewport =
    classifyDevice
        { height = round viewport.viewport.height
        , width = round viewport.viewport.width
        }
