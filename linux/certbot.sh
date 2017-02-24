#!/bin/bash

certbot certonly -v --noninteractive --agree-tos --email ntaxa@ntaxa.com --webroot --webroot-path /var/www/html -d $1

