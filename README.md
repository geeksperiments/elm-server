# elm-server

Loosely based off of [ianmackenzie/elm-script](https://github.com/ianmackenzie/elm-script), [F#'s giraffe](https://github.com/giraffe-fsharp/Giraffe), and [Haskell's Servant](https://www.servant.dev/).

## WARNING THIS IS JUST FOR FUN NOT FOR PRODUCTION

## Basic Example:

```Elm
module HelloWorld exposing (main)

import Logger as Log
import Response
import Server exposing (Config, Flags, Request, Response)


main : Server.Program
main =
    Server.program
        { init = init
        , handler = handler
        }


init : Flags -> Config
init _ =
    Server.baseConfig


handler : Request -> Response
handler request =
    case Server.matchPath request of
        Result.Ok [] ->
            Server.respond request (Response.default |> Response.setBody "Hello, Elm Server!")
                |> Server.andThen (\_ -> Log.toConsole "index page requested")

        Result.Ok [ "hello", name ] ->
            Log.toConsole ("Saying hello to " ++ name)
                |> Server.andThen
                    (\_ ->
                        Response.default
                            |> Response.setBody ("Hello, " ++ name ++ "!")
                            |> Server.respond request
                    )

        Result.Ok _ ->
            Server.respond request Response.notFound

        Err err ->
            Server.respond request (Response.error err)
```

## Other Examples:

- [Hello World](./examples/HelloWorld.elm)
    - Your most basic examples
- [HTTPS](./examples/SecureWorld.elm) (You'll need to create your own certs if you want to try this one out.)
    - Extension of Hello World to show HTTPS
- [Load a file](./examples/HelloFile.elm), pairs with [HelloClient.elm](./examples/HelloClient.elm)
    - Shows loading a file from a local directory and returning the contents to the user
- [Database (Postgres)](./examples/HelloDBServer.elm), pairs with [Person.elm](./examples-db/Person.elm) and [HelloDBClient.elm](./examples/HelloDBClient.elm)
    - A simple client and server written in Elm. Only supports basic GET, POST, DELETE
    - Shows off sharing code between front and back end

All examples (listed and otherwise) can be found in [examples](./examples).

## Try it out:

1. clone this repo
1. install [Deno](https://deno.land/)
1. from the cloned repo run `./build.sh`
    - this compiles the js glue code which creates a command called `elm-server`
1. run `elm-server start path/to/YourServer.elm`
    - this starts your server

## Docs:

Too unstable to start writing docs.
