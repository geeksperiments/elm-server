module Internal.Server exposing
    ( Certs
    , Config(..)
    , ConfigData
    , Query(..)
    , RequestData
    , Type(..)
    , query
    , runTask
    )

import Http
import Json.Decode
import Json.Encode exposing (Value)
import Status exposing (Status(..))
import Task exposing (Task)


type alias RequestData =
    { request : Value
    , requestId : String
    }


type Config
    = Config ConfigData


type alias ConfigData =
    { port_ : Int
    , type_ : Type
    , databaseConnection : Maybe DatabaseConnection
    , envPath : List String
    }


type alias DatabaseConnection =
    { hostname : String
    , port_ : Int
    , user : String
    , password : String
    , database : String
    }


type Type
    = Basic
    | Secure Certs


type alias Certs =
    { certificatePath : String
    , keyPath : String
    }


runTask : String -> Value -> Task String Value
runTask name value =
    Http.task
        { method = "POST"
        , headers = []
        , url = "/runner"
        , body =
            [ ( "msg", Json.Encode.string name )
            , ( "args", value )
            ]
                |> Json.Encode.object
                |> Http.jsonBody
        , timeout = Nothing
        , resolver =
            (\response ->
                case response of
                    Http.BadUrl_ url ->
                        "Javscript Error: Bad Url: "
                            ++ url
                            |> Err

                    Http.Timeout_ ->
                        Err "Javascript took too long to respond"

                    Http.NetworkError_ ->
                        Err "Unknown javascript error resulted in a 'Network Error'"

                    Http.BadStatus_ _ body ->
                        Err body

                    Http.GoodStatus_ _ body ->
                        Json.Decode.decodeString Json.Decode.value body
                            |> Result.mapError Json.Decode.errorToString
            )
                |> Http.stringResolver
        }


type Query
    = Query String


query : Query -> Task String Value
query (Query qry) =
    qry
        |> Json.Encode.string
        |> runTask "DATABASE_QUERY"
