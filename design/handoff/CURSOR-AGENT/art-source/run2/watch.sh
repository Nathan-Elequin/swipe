while ! grep -q 'raw/s64_run' q3.out; do sleep 0.1; done
pkill -STOP -f "python3 -u q3.py"; pkill -KILL -f "python3 -u q3.py"; echo killed >> watch.log
