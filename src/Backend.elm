module Backend exposing (..)

import Dict
import Dict.Extra as DE
import Env
import Html
import Http
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode exposing (float)
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
    ( { message = "Hello!", counter = 0, sessions = Dict.empty }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        GetOpenAIResponse clientId openAIResponse ->
            ( model, Lamdera.sendToFrontend clientId <| ReceiveOpenAIResponse openAIResponse )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        ReceiveQuestion question ->
            ( { model | counter = model.counter + 1 }
            , if model.counter < 30 then
                Cmd.batch
                    [ Http.request
                        { method = "POST"
                        , headers = [ Http.header "Authorization" ("Bearer " ++ Env.openAIApiKey) ]
                        , url = "https://api.openai.com/v1/engines/davinci/completions"
                        , body =
                            Http.jsonBody <|
                                object
                                    [ ( "prompt", string <| addExamples question )
                                    , ( "max_tokens", int 220 )
                                    , ( "temperature", float 0.5 )
                                    , ( "top_p", int 1 )
                                    , ( "n", int 1 )
                                    , ( "stop", string "###" )
                                    ]
                        , expect = Http.expectJson (GetOpenAIResponse clientId) decodeOpenAIResponse
                        , timeout = Nothing
                        , tracker = Nothing
                        }
                    , Lamdera.broadcast <| ReceiveCounter <| model.counter + 1
                    ]

              else
                Lamdera.sendToFrontend clientId TooMuchQuestions
            )

        GetCounter ->
            ( model, Lamdera.sendToFrontend clientId <| ReceiveCounter model.counter )

        ReceivePassword password ->
            let
                ( newSessions, cmd ) =
                    if Env.password == password then
                        ( Dict.insert sessionId clientId model.sessions, Lamdera.sendToFrontend clientId <| LoggedIn )

                    else
                        ( model.sessions, Cmd.none )
            in
            ( { model | sessions = newSessions }, cmd )

        GetSession ->
            ( model
            , case DE.find (\sessionId_ _ -> sessionId == sessionId_) model.sessions of
                Just session ->
                    Lamdera.sendToFrontend clientId <| LoggedIn

                Nothing ->
                    Cmd.none
            )


decodeOpenAIResponse : Decoder OpenAIResponse
decodeOpenAIResponse =
    succeed OpenAIResponse
        |> required "id" decoderString
        |> required "object" decoderString
        |> required "created" decoderInt
        |> required "model" decoderString
        |> required "choices" (decoderList choiceDecoder)


choiceDecoder : Decoder Choice
choiceDecoder =
    succeed Choice
        |> required "text" decoderString
        |> required "index" decoderInt
        |> optional "logprobs" decoderInt 0
        |> optional "finish_reason" decoderString ""


addExamples : String -> String
addExamples question =
    """This is a financial advisor that loves TimelineApp, green energy and super polite.
Q: What do I value the most?
A: Start by making a list of everything you spend money on by reviewing your bank and credit card statements. Some expenses, such as student loan payments, can’t be eliminated from your budget. But you may decide that weekly Postmates™ orders aren’t essential. By ranking each expense, it may be easier to see where you can make changes over time.
###
Q: Can I save more?
A: If you aren’t sure how much you’re saving, it may be time to take a closer look at your what percentage of your income you’re setting aside for the future. There is no rule of thumb for how much you should be saving that applies to everyone. But if you can afford to save more, experts agree you should try.
###
Q: How am I financially protecting my loved ones?
A: The best way to figure out how much life insurance coverage you might need, and how much you’re eligible for, is to use an online life insurance calculator. In a few minutes, it can help you determine you and your family’s needs, and give you a personalized quote for term life insurance coverage.
###
Q: How can I avoid tax as a British?
A: The United Kingdom has a progressive tax system, meaning that those who earn the most pay the highest rates of income tax. The top 10% of earners in the UK pay over 50% of all income tax, and the top 1% pay over a quarter of all income tax.
The top rate income tax in the UK is 45%, which applies to income over £150,000. There is also a tax-free personal allowance of £11,850 in the UK, after which a 20% income tax rate applies.
###
Q: How can I maximise my rents?
A: In order to maximise rent, you have to get the best possible deal on your mortgage and on your rent. The best deals for mortgages are interest-only mortgages, where you only pay interest for a set period and then have a large repayment over a much longer period. With investment property, it is usually better to fix the mortgage rate for longer. With rent, it is better to negotiate a shorter lease.
The best deal is to have no mortgage and to pay no rent. To do this, you need to keep your rents low so that your investment yields a sufficient return.
###
Q: """ ++ question
