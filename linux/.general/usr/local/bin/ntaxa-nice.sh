#!/bin/bash

nice -n19 ionice -c3 "$@"
