module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Http exposing (Error)
import Lamdera exposing (ClientId)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , message : String
    , question : String
    , openAIResponse : Maybe OpenAIResponse
    , openAIState : OpenAIState
    , counter : Int
    }


type alias BackendModel =
    { message : String
    , openAIResponse : Maybe OpenAIResponse
    , counter : Int
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | TextChanged String
    | SubmitQuestion


type ToBackend
    = NoOpToBackend
    | ReceiveQuestion String
    | GetCounter


type BackendMsg
    = NoOpBackendMsg
    | GetOpenAIResponse ClientId (Result Error OpenAIResponse)


type ToFrontend
    = NoOpToFrontend
    | ReceiveOpenAIResponse OpenAIResponse
    | TooMuchQuestions
    | ReceiveCounter Int


type alias OpenAIResponse =
    { id : String
    , object : String
    , created : Int
    , model : String
    , choices : List Choice
    }


type alias Choice =
    { text : String
    , index : Int
    , logprobs : Int
    , finishReason : String
    }


type OpenAIState
    = Waiting
    | Thinking
    | Saturated
