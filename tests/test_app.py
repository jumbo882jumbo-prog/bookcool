"""
Unit and Integration Tests for Bookcool E-Book Store Web Application
Executed via Python unittest framework
"""
import unittest
import json
from app import app, ebooks_database

class BookcoolAppTestCase(unittest.TestCase):
    def setUp(self):
        """Set up test client and configure test environment"""
        self.app = app
        self.app.config['TESTING'] = True
        self.client = self.app.test_client()

    def test_01_index_page(self):
        """Test home / index page responds with status code 200"""
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'E-Book Store', response.data)

    def test_02_static_pages_load_successfully(self):
        """Test essential HTML pages are reachable"""
        routes = [
            '/login.html',
            '/cart.html',
            '/checkout.html',
            '/admin.html',
            '/my-books.html',
            '/reports.html',
            '/sql-console.html',
            '/reviews.html',
            '/book-detail.html',
            '/add-book.html'
        ]
        for route in routes:
            with self.subTest(route=route):
                response = self.client.get(route)
                self.assertEqual(response.status_code, 200, f"Failed loading {route}")

    def test_03_search_functionality(self):
        """Test search query filtering on index page"""
        response = self.client.get('/?search=Startup')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Lean Startup', response.data)

    def test_04_category_filter(self):
        """Test category filtering on index page"""
        response = self.client.get('/?category=' + 'ธุรกิจ & การตลาด')
        self.assertEqual(response.status_code, 200)

    def test_05_api_get_books(self):
        """Test REST API endpoint GET /api/books returns valid list of books"""
        response = self.client.get('/api/books')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertIsInstance(data, list)
        self.assertGreater(len(data), 0)
        # Verify book schema structure
        sample_book = data[0]
        self.assertIn('ebook_id', sample_book)
        self.assertIn('title', sample_book)
        self.assertIn('price', sample_book)
        self.assertIn('category_name', sample_book)

    def test_06_api_post_new_book(self):
        """Test REST API endpoint POST /api/books adds a new book successfully"""
        new_book_payload = {
            "title": "Automated Testing Masterclass",
            "author": "Antigravity CI",
            "price": 350.00,
            "category": "เทคโนโลยี & การเขียนโปรแกรม",
            "description": "Comprehensive guide to automated testing and continuous integration"
        }
        response = self.client.post('/api/books',
                                  data=json.dumps(new_book_payload),
                                  content_type='application/json')
        self.assertEqual(response.status_code, 201)
        res_data = json.loads(response.data)
        self.assertEqual(res_data.get('status'), 'success')
        self.assertEqual(res_data['book']['title'], 'Automated Testing Masterclass')
        self.assertEqual(res_data['book']['price'], 350.00)

    def test_07_api_post_empty_data_validation(self):
        """Test REST API endpoint POST /api/books handles missing payload properly"""
        response = self.client.post('/api/books',
                                  data="",
                                  content_type='application/json')
        self.assertEqual(response.status_code, 400)

    def test_08_database_integrity(self):
        """Test database seed integrity - verify initial book list has valid prices and IDs"""
        self.assertGreaterEqual(len(ebooks_database), 8)
        for book in ebooks_database:
            self.assertIsInstance(book['ebook_id'], int)
            self.assertGreater(book['price'], 0)
            self.assertTrue(len(book['title']) > 0)

if __name__ == '__main__':
    unittest.main()
