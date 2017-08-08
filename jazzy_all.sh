#!/bin/bash
./jazzy_run.sh \  appudo_websocket appudo_page
./jazzy_run.sh _Page appudo_websocket libappudo libassert
./jazzy_run.sh _WebSocket appudo_page libappudo libassert
