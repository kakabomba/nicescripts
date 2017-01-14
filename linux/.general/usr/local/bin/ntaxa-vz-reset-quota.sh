#!/bin/bash

vzctl stop $1
vzquota drop $1
vzctl start $1
