import requests
import time

WEBHOOK = "your_discord_webhook"

def send_discord(msg):
    requests.post(WEBHOOK, json={"content": msg})

def monitor_ban_log():
    known = set()
    while True:
        try:
            with open("ban_log.txt", "r") as f:
                lines = f.readlines()
            for line in lines:
                if line not in known:
                    known.add(line)
                    send_discord(f"🚫 {line.strip()}")
        except:
            pass
        time.sleep(5)

monitor_ban_log()
