#!/usr/bin/env bash

doppler run --token=$DOPPLER_TOKEN -- \
    java -jar app.jar --spring.profiles.active=$SPRING_ACTIVE_PROFILE
