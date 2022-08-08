#!/bin/sh

sed 's/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' < prueba > prueba2 &
mv prueba2 prueba &
