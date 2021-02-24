#!/bin/bash

APP_PATH=$(cd `dirname $0`; pwd)/app.jar
COMMAND=${1:-usage}
ENV=${2:-local}
ENCRYPTOR_PASSWORD=${3:-ukeplus}

usage() {
  echo 'Usage: sh app.sh [start|stop|restart|status] [ENV] [ENCRYPTOR_PASSWORD]'
  exit 1
}

is_exist(){
  PID=`ps -ef | grep $APP_PATH | grep -v grep | awk '{print $2}'`
  if [ -z $PID ]; then
    return 1
  else
    return 0
  fi
}

start(){
  is_exist
  if [ $? -eq 0 ]; then
    echo "app is already running. pid=${PID}"
  else
    nohup java \
      -Dspring.profiles.active=$ENV \
      -Djasypt.encryptor.password=$ENCRYPTOR_PASSWORD \
      -jar $APP_PATH > /dev/null 2>&1 &
  fi
}

stop(){
  is_exist
  if [ $? -eq 0 ]; then
    kill -9 $PID
  else
    echo "app is not running"
  fi
}

status(){
  is_exist
  if [ $? -eq 0 ]; then
    echo "app is running. pid=${PID}"
    return 1
  else
    echo "app is NOT running."
    return 0
  fi
}

health() {
  status
  if [ $? -eq 0 ]; then
    exit 1
  else
    echo "health: UP"
  fi
}

restart(){
  stop
  sleep 5
  start
}

case $COMMAND in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  restart)
    restart
    ;;
  health)
    health
    ;;
  *)
    usage
    ;;
esac
