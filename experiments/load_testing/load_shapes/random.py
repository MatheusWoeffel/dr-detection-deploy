from locust import LoadTestShape
import random

random.seed(42)

class RandomLoadShape(LoadTestShape):
    time_limit = 300 # 5 minutes
    max_number_of_users = 40
    current_number_of_users = 10

    def tick(self):
        run_time = self.get_run_time()

        if run_time < self.time_limit:
            self.current_number_of_users = random.randrange(10,41) # Choose between 10 and 40 users
        
            return (self.current_number_of_users, 100)

        return None