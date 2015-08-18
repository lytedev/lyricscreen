# lyricscreen

A simple lyrics/words display and management app.

## Prerequisites

All you need is `npm`. Oh, and the following modules installed globally:

* `bower`
* `gulp`
* `electron-prebuilt`

You can get them with the following command:

    npm install -g bower gulp electron-prebuilt

## Setup

To setup the project, we need to clone the repo, checkout the proper branch,
install dependencies for the app and client, build the client, and we're set!

    git clone https://github.com/lytedev/lyricscreen
    cd lyricscreen
    git checkout electron-dev
    npm install
    bower install
    gulp

## Running

    electron ./

## Structure

`src/backend` contains, well, all the logic for the backend of the application.
This is separated into 4 main components:

* `lyricscreen`: The core logic surrounding the app.
* `http`: The server for the web client.
* `websocket`: The server for receiving commands for accessing core
    functionality.
* `windows`: The logic for the various "native" windows.

`src/client` is the web client code which gets built by gulp to
`src/client/build`.
