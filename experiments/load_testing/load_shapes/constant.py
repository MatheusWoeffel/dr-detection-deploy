from locust import LoadTestShape

class ConstantLoadShape(LoadTestShape):
    time_limit = 300 # 5 minutes
    spawn_rate = 40

    def tick(self):
        run_time = self.get_run_time()

        if run_time < self.time_limit:
            return (self.spawn_rate, self.spawn_rate)

        return None