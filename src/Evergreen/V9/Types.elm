module Evergreen.V9.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Dict
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
    , loggedIn : Bool
    }


type alias BackendModel =
    { message : String
    , counter : Int
    , sessions : Dict.Dict Lamdera.SessionId Lamdera.ClientId
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | ReceiveViewport (Result Http.Error Browser.Dom.Viewport)
    | GotNewSize Int Int
    | QuestionChanged String
    | SubmitQuestion
    | PasswordChanged String
    | SubmitPassword


type ToBackend
    = NoOpToBackend
    | ReceiveQuestion String
    | ReceivePassword String
    | GetCounter
    | GetSession


type BackendMsg
    = NoOpBackendMsg
    | GetOpenAIResponse Lamdera.ClientId (Result Http.Error OpenAIResponse)


type ToFrontend
    = NoOpToFrontend
    | ReceiveOpenAIResponse (Result Http.Error OpenAIResponse)
    | TooMuchQuestions
    | ReceiveCounter Int
    | LoggedIn
