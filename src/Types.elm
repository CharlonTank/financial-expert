module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Dom exposing (Viewport)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Element exposing (Device)
import Http exposing (Error)
import Lamdera exposing (ClientId, SessionId)
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
    , loggedIn : Bool
    }


type alias BackendModel =
    { message : String
    , counter : Int
    , sessions : Dict SessionId ClientId
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | ReceiveViewport (Result Error Viewport)
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
    | GetOpenAIResponse ClientId (Result Error OpenAIResponse)


type ToFrontend
    = NoOpToFrontend
    | ReceiveOpenAIResponse (Result Error OpenAIResponse)
    | TooMuchQuestions
    | ReceiveCounter Int
    | LoggedIn


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
