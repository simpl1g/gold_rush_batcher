# README

## Start everything

```
chmod +x start.sh
./start.sh
```

Reset redis if you want to start from scratch

```
docker-compose exec redis-master redis-cli flushall
```

## Testing

Send single events with curl
```
curl -X POST 'http://127.0.0.1/events?event=evt1'
```
After a minute you should see in logs
```
netcat_1        | Events count: 1
netcat_1        | Events: evt1
```
Or you can run wrk script to concurrently post random events from paths.txt
This file contains 200 uniq events 
```
brew install wrk
wrk -c 20 -t 4 -d 10s --timeout 1m -s wrk.lua http://localhost
```

## Basic architecture
Application includes:
1. Web. Rack application with /events endpoint. Receives event and stores in redis Set. 
If event uniq it get pushed to list, after having 10 events in this list, they grabbed and directly sent to netcat server
This can be improved to use separate queue and BLPOP in consumer, to not have logic of sending to netcat in broker 
2. Consumer. Ruby script to subscribe for redis expire event. Will be triggered after 1 minute without new events
3. Netcat. Basic Rack application to log incoming batch events

## Note about Rails
I decided to use plain Rack because there is no need in any Rails functionality and it only adds extra overhead.

## Tests
I Added a simple example unit test in rspec, but not covered everything with tests. 
Full coverage will require extra work that can be done by extra request