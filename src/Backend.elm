module Backend exposing (..)

import Dict
import Env
import Html
import Http
import Json.Decode.Pipeline exposing (optional, required)
import Lamdera exposing (ClientId, SessionId)
import Lamdera.Json exposing (..)
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { message = "Hello!" }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        GetOpenAIResponse (Ok _) ->
            ( model, Cmd.none )

        GetOpenAIResponse (Err _) ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        ReceiveQuestion question ->
            ( model
              -- , Http.get
              --     -- { method = "GET"
              --     -- , headers = []
              --     { url = "https://api.openai.com/v1/engines/davinci/completions/browser_stream\n"
              --     -- , body = Http.emptyBody
              --     , expect = Http.expectJson GetOpenAIResponse decodeOpenAIResponse
              --     -- , timeout = Nothing
              --     -- , withCredentials = False
              --     }
            , Http.request
                { method = "POST"
                , headers = [ Http.header "Authorization" ("Bearer " ++ Env.openAIApiKey) ]
                , url = "https://api.openai.com/v1/engines/davinci/completions"
                , body =
                    Http.jsonBody <|
                        object
                            [ ( "prompt", string question )
                            , ( "max_tokens", int 30 )
                            ]
                , expect = Http.expectJson GetOpenAIResponse decodeOpenAIResponse
                , timeout = Nothing
                , tracker = Nothing
                }
            )


decodeOpenAIResponse : Decoder OpenAIResponse
decodeOpenAIResponse =
    succeed OpenAIResponse
        |> required "id" decoderString
        |> required "object" decoderString
        |> required "created" decoderInt
        |> required "model" decoderString
        |> required "choices" (decoderList choiceDecoder)



-- "id": "cmpl-GxetY7rxbQDVuGoMhX19c8Qy", "object": "text_completion", "created": 1592103423, "choices": [{"text": ",", "index": 0, "logprobs": null, "finish_reason": null}], "model": "davinci:2020-05-03"


choiceDecoder : Decoder Choice
choiceDecoder =
    succeed Choice
        |> required "text" decoderString
        |> required "index" decoderInt
        |> optional "logprobs" decoderInt 0
        |> optional "finish_reason" decoderString ""
