module WebAPI.ScreenTest where

import ElmTest.Test exposing (..)
import ElmTest.Assertion exposing (..)
import Task exposing (Task, sequence, succeed, andThen)

import WebAPI.Screen exposing (..)


screenTest : Task () Test
screenTest =
    screen |>
        Task.map (\s ->
            test "screen" <<
                assert <|
                    List.all ((flip (>=)) 0) <|
                        List.map ((|>) s)
                            [ .availTop
                            , .availLeft
                            , .availHeight
                            , .availWidth
                            , .colorDepth
                            , .pixelDepth
                            , .height
                            , .width
                            ]
        )

tests : Task () Test
tests =
    Task.map (suite "Screen") <|
        sequence <|
            [ screenTest
            ]

