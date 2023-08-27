from locust import LoadTestShape

class IncrementalLoadShape(LoadTestShape):
    time_limit = 300 # 5 minutes
    max_user_count = 40

    def tick(self):
        run_time = self.get_run_time()

        if run_time < self.time_limit:
            return (self.max_user_count, 1)

        return None