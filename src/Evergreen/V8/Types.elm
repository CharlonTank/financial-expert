module Evergreen.V8.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Element
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
    | Error Http.Error


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , message : String
    , device : Maybe Element.Device
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
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | ReceiveViewport (Result Http.Error Browser.Dom.Viewport)
    | GotNewSize Int Int
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
    | ReceiveOpenAIResponse (Result Http.Error OpenAIResponse)
    | TooMuchQuestions
    | ReceiveCounter Int
