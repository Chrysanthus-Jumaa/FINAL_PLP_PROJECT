import requests
import json

BASE_URL = 'http://127.0.0.1:8000/api'

# Store tokens
restorer_token = None
org_token = None
land_listing_id = None
match_request_id = None

print("=" * 60)
print("COMPREHENSIVE API TEST")
print("=" * 60)

# Test 1: Get Counties
print("\n1. GET COUNTIES")
response = requests.get(f'{BASE_URL}/counties/')
print(f"Status: {response.status_code}")
print(f"Counties count: {len(response.json())}")

# Test 2: Get Subcounties for Nairobi (county_id=30)
print("\n2. GET SUBCOUNTIES (Nairobi)")
response = requests.get(f'{BASE_URL}/counties/30/subcounties/')
print(f"Status: {response.status_code}")
print(f"Subcounties count: {len(response.json())}")

# Test 3: Get Restoration Types
print("\n3. GET RESTORATION TYPES")
response = requests.get(f'{BASE_URL}/restoration-types/')
print(f"Status: {response.status_code}")
print(f"Types: {[t['display_name'] for t in response.json()]}")

# Test 4: Register Restorer
print("\n4. REGISTER RESTORER")
restorer_data = {
    "email": "jane.smith@test.com",
    "password": "testpass123",
    "confirm_password": "testpass123",
    "role": "restorer",
    "first_name": "Jane",
    "last_name": "Smith",
    "phone": "0722334455",
    "county": 30,
    "subcounty": 2,
    "restoration_type_ids": [1, 3],  # Forest and Wetlands
    "terms_accepted": True
}
response = requests.post(f'{BASE_URL}/register/', json=restorer_data)
print(f"Status: {response.status_code}")
if response.status_code == 201:
    print(f"Restorer created: {response.json()['user']['email']}")

# Test 5: Login Restorer
print("\n5. LOGIN RESTORER")
response = requests.post(f'{BASE_URL}/login/', json={
    "email": "jane.smith@test.com",
    "password": "testpass123"
})
print(f"Status: {response.status_code}")
if response.status_code == 200:
    restorer_token = response.json()['access']
    print("Token received ✓")

# Test 6: Create Land Listing
print("\n6. CREATE LAND LISTING")
headers = {'Authorization': f'Bearer {restorer_token}'}
land_data = {
    "title": "Green Valley Farm",
    "size": 10,
    "unit": "acres",
    "county": 30,
    "subcounty": 2,
    "restoration_type_ids": [1, 3],
    "availability": "available"
}
response = requests.post(f'{BASE_URL}/lands/', json=land_data, headers=headers)
print(f"Status: {response.status_code}")
if response.status_code == 201:
    land_listing_id = response.json()['id']
    print(f"Land created: ID {land_listing_id}")
    print(f"Size: {response.json()['size_acres']} acres = {response.json()['size_hectares']} hectares")

# Test 7: Get Restorer's Land Listings
print("\n7. GET RESTORER LAND LISTINGS")
response = requests.get(f'{BASE_URL}/lands/', headers=headers)
print(f"Status: {response.status_code}")
print(f"Listings count: {len(response.json())}")

# Test 8: Register Organization
print("\n8. REGISTER ORGANIZATION")
org_data = {
    "email": "ecofriendly@test.com",
    "password": "testpass123",
    "confirm_password": "testpass123",
    "role": "organization",
    "organization_name": "EcoFriendly Projects",
    "terms_accepted": True
}
response = requests.post(f'{BASE_URL}/register/', json=org_data)
print(f"Status: {response.status_code}")
if response.status_code == 201:
    print(f"Organization created: {response.json()['user']['organization_name']}")

# Test 9: Login Organization
print("\n9. LOGIN ORGANIZATION")
response = requests.post(f'{BASE_URL}/login/', json={
    "email": "ecofriendly@test.com",
    "password": "testpass123"
})
print(f"Status: {response.status_code}")
if response.status_code == 200:
    org_token = response.json()['access']
    print("Token received ✓")

# Test 10: Organization Views Available Lands
print("\n10. ORGANIZATION VIEWS AVAILABLE LANDS")
headers_org = {'Authorization': f'Bearer {org_token}'}
response = requests.get(f'{BASE_URL}/lands/', headers=headers_org)
print(f"Status: {response.status_code}")
print(f"Available lands: {len(response.json())}")
if len(response.json()) > 0:
    print(f"First land: {response.json()[0]['title']}")

# Test 11: Organization Creates Match Request
print("\n11. CREATE MATCH REQUEST")
response = requests.post(
    f'{BASE_URL}/match-requests/create/',
    json={"land_listing_id": land_listing_id},
    headers=headers_org
)
print(f"Status: {response.status_code}")
if response.status_code == 201:
    match_request_id = response.json()['match_request']['id']
    print(f"Match request created: ID {match_request_id}")

# Test 12: Restorer Views Notifications
print("\n12. RESTORER VIEWS NOTIFICATIONS")
headers_restorer = {'Authorization': f'Bearer {restorer_token}'}
response = requests.get(f'{BASE_URL}/notifications/', headers=headers_restorer)
print(f"Status: {response.status_code}")
print(f"Unread notifications: {len(response.json())}")
if len(response.json()) > 0:
    print(f"Latest: {response.json()[0]['message']}")

# Test 13: Restorer Views Match Requests
print("\n13. RESTORER VIEWS MATCH REQUESTS")
response = requests.get(f'{BASE_URL}/match-requests/', headers=headers_restorer)
print(f"Status: {response.status_code}")
print(f"Match requests: {len(response.json())}")
if len(response.json()) > 0:
    print(f"Status: {response.json()[0]['status']}")

# Test 14: Restorer Accepts Match Request
print("\n14. RESTORER ACCEPTS MATCH REQUEST")
response = requests.post(
    f'{BASE_URL}/match-requests/{match_request_id}/update-status/',
    json={"action": "accept"},
    headers=headers_restorer
)
print(f"Status: {response.status_code}")
if response.status_code == 200:
    print(f"Match accepted ✓")

# Test 15: Organization Views Notifications (Should see acceptance)
print("\n15. ORGANIZATION VIEWS NOTIFICATIONS")
response = requests.get(f'{BASE_URL}/notifications/', headers=headers_org)
print(f"Status: {response.status_code}")
print(f"Unread notifications: {len(response.json())}")
if len(response.json()) > 0:
    print(f"Latest: {response.json()[0]['message']}")

# Test 16: Check Land is Now Unavailable
print("\n16. CHECK LAND AVAILABILITY")
response = requests.get(f'{BASE_URL}/lands/{land_listing_id}/', headers=headers_restorer)
print(f"Status: {response.status_code}")
if response.status_code == 200:
    print(f"Availability: {response.json()['availability']}")

# Test 17: Try to Delete Land (Should fail - has accepted request)
print("\n17. TRY TO DELETE LAND (Should fail)")
response = requests.delete(f'{BASE_URL}/lands/{land_listing_id}/', headers=headers_restorer)
print(f"Status: {response.status_code}")
if response.status_code == 400:
    print("Deletion blocked ✓")

print("\n" + "=" * 60)
print("ALL TESTS COMPLETE!")
print("=" * 60)