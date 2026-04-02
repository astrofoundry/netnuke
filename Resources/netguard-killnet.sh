#!/bin/bash
sleep 2
while IFS= read -r service; do
    [[ -z "$service" ]] && continue
    service="${service#\*}"
    networksetup -setnetworkserviceenabled "$service" off
done < <(networksetup -listallnetworkservices | tail -n +2)
