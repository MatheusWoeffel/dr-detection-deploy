from locust import LoadTestShape

class SpikeLoadTestShape(LoadTestShape):
    time_limit = 300  # 5 minutes
    spike_duration = 5  # Duration of each spike in seconds
    normal_rps = 20  # Requests per second during normal period
    spike_rps = 40  # Requests per second during spike
    pattern_duration = 20

    def tick(self):
        run_time = self.get_run_time()

        if run_time < self.time_limit:
            pattern_time = run_time % self.pattern_duration

            if pattern_time < self.spike_duration: 
                return (self.spike_rps, self.spike_rps)

            return (self.normal_rps, self.normal_rps)

        return None