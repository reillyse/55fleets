#!/usr/bin/env bash

num_workers=${SIDEKIQ_WORKERS:=1}
max_memory=${SIDEKIQ_MAX_MEMORY:=1000000} # 1GB
sidekiq_config=${SIDEKIQ_CONFIG:=config/sidekiq.yml}

function finish {
        echo "Shutting down Sidekiq workers..."
        for i in `seq 1 $num_workers`; do
        bundle exec sidekiqctl stop tmp/pids/sidekiq-$i.pid 4 &
        done
    wait
    exit 0
}
trap finish SIGHUP SIGINT SIGTERM

echo "Starting Sidekiq workers..."
bundle exec rake db:migrate
touch log/sidekiq.log
for i in `seq 1 $num_workers`; do
    bundle exec sidekiq -C $sidekiq_config -L /dev/stdout   -i $i -P tmp/pids/sidekiq-$i.pid -d
done

while true; do
    sleep 60 &
    wait

    for i in `seq 1 $num_workers`; do
        cat tmp/pids/sidekiq-${i}.pid
        if [ $? -ne 0 ]; then
           echo "Can't find PID restarting Sidekiq:$i..."
           bundle exec sidekiq -C $sidekiq_config -L /dev/stdout -i $i -P tmp/pids/sidekiq-$i.pid -d
           sleep 2

        fi
        pid=$(cat tmp/pids/sidekiq-${i}.pid)
        rss=$(cat /proc/${pid}/status | grep VmRSS | awk '{print $2}')
        now=$(date +"%T")
        echo "[$now] Sidekiq:$i memory usage: $rss KB"
        if [ $rss ] && [ $rss -gt $max_memory ]; then
            bundle exec sidekiqctl stop tmp/pids/sidekiq-$i.pid 120
            sleep 1
            echo "Starting Sidekiq:$i..."
            bundle exec sidekiq -C $sidekiq_config -L /dev/stdout -i $i -P tmp/pids/sidekiq-$i.pid -d
        fi

    done
done
