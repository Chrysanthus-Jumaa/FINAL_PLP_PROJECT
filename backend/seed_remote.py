import requests

response = requests.post(
    'https://zingiranakama-proj2.onrender.com/api/seed-database/',
    data={'secret': 'seed-my-database-now'}
)

print(f"Status: {response.status_code}")
print(f"Response: {response.json()}")