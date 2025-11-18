import requests
import json

BASE_URL = 'http://127.0.0.1:8000/api'

# Test 1: Register a restorer
print("=" * 50)
print("TEST 1: Register Restorer")
print("=" * 50)

restorer_data = {
    "email": "john.doe@test.com",
    "password": "testpass123",
    "confirm_password": "testpass123",
    "role": "restorer",
    "first_name": "John",
    "last_name": "Doe",
    "phone": "0712345678",
    "county": 30,  # Nairobi
    "subcounty": 1,  # Westlands (adjust based on your seeded data)
    "restoration_type_ids": [1, 2],  # Forest and Agroforestry
    "terms_accepted": True
}

response = requests.post(f'{BASE_URL}/register/', json=restorer_data)
print(f"Status: {response.status_code}")
print(f"Response: {json.dumps(response.json(), indent=2)}")

# Test 2: Login
print("\n" + "=" * 50)
print("TEST 2: Login")
print("=" * 50)

login_data = {
    "email": "john.doe@test.com",
    "password": "testpass123"
}

response = requests.post(f'{BASE_URL}/login/', json=login_data)
print(f"Status: {response.status_code}")
print(f"Response: {json.dumps(response.json(), indent=2)}")

if response.status_code == 200:
    token = response.json()['access']
    
    # Test 3: Get Profile
    print("\n" + "=" * 50)
    print("TEST 3: Get Profile (with token)")
    print("=" * 50)
    
    headers = {'Authorization': f'Bearer {token}'}
    response = requests.get(f'{BASE_URL}/profile/', headers=headers)
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")

# Test 4: Register an organization
print("\n" + "=" * 50)
print("TEST 4: Register Organization")
print("=" * 50)

org_data = {
    "email": "greenearth@test.com",
    "password": "testpass123",
    "confirm_password": "testpass123",
    "role": "organization",
    "organization_name": "GreenEarth Initiative",
    "terms_accepted": True
}

response = requests.post(f'{BASE_URL}/register/', json=org_data)
print(f"Status: {response.status_code}")
print(f"Response: {json.dumps(response.json(), indent=2)}")