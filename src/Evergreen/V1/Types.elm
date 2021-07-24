module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Http
import Lamdera
import Url


type alias Choice =
    { text : String
    , index : Int
    , logprobs : Int
    , finishReason : String
    }


type alias OpenAIResponse =
    { id : String
    , object : String
    , created : Int
    , model : String
    , choices : List Choice
    }


type OpenAIState
    = Waiting
    | Thinking
    | Saturated


type alias FrontendModel =
    { key : Browser.Navigation.Key
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
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | TextChanged String
    | SubmitQuestion


type ToBackend
    = NoOpToBackend
    | ReceiveQuestion String
    | GetCounter


type BackendMsg
    = NoOpBackendMsg
    | GetOpenAIResponse Lamdera.ClientId (Result Http.Error OpenAIResponse)


type ToFrontend
    = NoOpToFrontend
    | ReceiveOpenAIResponse OpenAIResponse
    | TooMuchQuestions
    | ReceiveCounter Int
