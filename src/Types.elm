module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Dom exposing (Viewport)
import Browser.Navigation exposing (Key)
import Element exposing (Device)
import Http exposing (Error)
import Lamdera exposing (ClientId)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , message : String
    , device : Maybe Device
    , question : String
    , openAIResponse : Maybe OpenAIResponse
    , openAIState : OpenAIState
    , counter : Int
    , password : String
    }


type alias BackendModel =
    { message : String
    , counter : Int
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | ReceiveViewport (Result Error Viewport)
    | GotNewSize Int Int
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
    | ReceiveOpenAIResponse (Result Error OpenAIResponse)
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
    | Error Http.Error
