module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Http exposing (Error)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , message : String
    , question : String
    }


type alias BackendModel =
    { message : String
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


type BackendMsg
    = NoOpBackendMsg
    | GetOpenAIResponse (Result Error OpenAIResponse)


type ToFrontend
    = NoOpToFrontend


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
