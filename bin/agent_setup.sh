#!/bin/bash

### Setup script for agents.
mkdir "$HOME/develop"

# Set up Dart.
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list
sudo apt-get update -y
sudo apt-get install -y dart=3.10.0-1

dart run bin/obtain.dart --tag v0.31.0 --release-dir "$HOME/develop/pocketbase"
