#!/bin/bash
# restores worldcup db

psql -U postgres < worldcup.sql
