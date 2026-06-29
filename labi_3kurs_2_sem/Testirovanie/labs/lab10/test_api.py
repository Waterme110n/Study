import unittest
import requests


#fact facts breeds
url = "https://catfact.ninja/fact"

class TestCatFactAPI(unittest.TestCase):

    def test_get_fact_success(self):
        response = requests.get("https://catfact.ninja/fact")
        self.assertEqual(response.status_code, 200)
        self.assertIn('fact', response.json())

    def test_get_fact_invalid_url(self):
        response = requests.get("https://catfact.ninja/factses")
        self.assertEqual(response.status_code, 404)

    def test_get_fact_invalid_headers(self):
        headers = {'Authorization': 'Bearer invalid_token'}
        response = requests.get("https://catfact.ninja/fact", headers=headers)
        self.assertEqual(response.status_code, 200)

user_url = "http://localhost:5000/api/v1/users"

class TestUserAPI(unittest.TestCase):
    def setUp(self):
        self.user_data = {
            "name": "Osadchy Pavel",
            "email": "pavel@example.com"
        }

        response = requests.post(user_url, json=self.user_data)
        self.assertEqual(response.status_code, 201)
        self.user_id = response.json()['id']

    def test_create_user(self):
        response = requests.post(user_url, json=self.user_data)
        self.assertEqual(response.status_code, 201)
        self.user_id = response.json()['id']
        self.assertEqual(self.user_data['name'], response.json()['name'])
        self.assertEqual(self.user_data['email'], response.json()['email'])

    def test_read_user(self):
        response = requests.get(f"{user_url}/{self.user_id}")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['id'], self.user_id)
        self.assertEqual(response.json()['name'], self.user_data['name'])

    def test_update_user(self):
        updated_data = {
            "email": "123@example.com"
        }
        response = requests.put(f"{user_url}/{self.user_id}", json=updated_data)
        self.assertEqual(response.status_code, 200)

        response = requests.get(f"{user_url}/{self.user_id}")
        self.assertEqual(response.json()['email'], updated_data['email'])

    def test_delete_user(self):
        response = requests.delete(f"{user_url}/{self.user_id}")
        self.assertEqual(response.status_code, 204)

        response = requests.get(f"{user_url}/{self.user_id}")
        self.assertEqual(response.status_code, 404)

class TestErrorUserAPI(unittest.TestCase):

    def test_empty_request_body(self):
        response = requests.post(user_url, json={})
        self.assertEqual(response.status_code, 400)
        print("Ошибка:",response.status_code, response.json())

    def test_delete_user(self):
        response = requests.delete(f"{user_url}/1000")
        self.assertEqual(response.status_code, 404)
        print("Ошибка:",response.status_code, response.json())

class TestValidationUserAPI(unittest.TestCase):

    def test_incorrect_email(self):
        user_data = {"name": "UserName", "email": "userexample.com"}
        response = requests.post(user_url, json=user_data)
        self.assertEqual(response.status_code, 400)
        print("Ошибка:",response.status_code, response.json())

    def test_invalid_username(self):
        user_data = {"name": "User@Name", "email": "user@example.com"}
        response = requests.post(user_url, json=user_data)
        self.assertEqual(response.status_code, 400)
        print("Ошибка:",response.status_code, response.json())

class TestPaginationAPI(unittest.TestCase):
    def setUp(self):
        self.user_data = [
            {"name": f"User {i}", "email": f"user{i}@example.com"} for i in range(1, 2)
        ]
        self.user_ids = []

        for data in self.user_data:
            response = requests.post(user_url, json=data)
            self.assertEqual(response.status_code, 201)
            self.user_ids.append(response.json()['id'])

    def test_pagination(self):
        response = requests.get(user_url, params={'page': 1, 'limit': 5})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.json()), 5)


    def test_empty_page(self):
        response = requests.get(user_url, params={'page': 5, 'limit': 5})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.json()), 0)

    def test_invalid_page(self):
        response = requests.get(user_url, params={'page': -1, 'limit': 5})
        self.assertEqual(response.status_code, 400)

        response = requests.get(user_url, params={'page': 1, 'limit': -5})
        self.assertEqual(response.status_code, 400)