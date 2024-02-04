import schedule
import time

def job():
     print("Job is running...")

# Schedule the job to be run every minute
schedule.every(1).minutes.do(job)

if __name__ == "__main__":
    while True:
        schedule.run_pending()
        time.sleep(1)
