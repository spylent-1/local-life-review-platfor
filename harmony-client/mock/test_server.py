import json
import threading
import unittest
from urllib.error import HTTPError
from urllib.parse import quote
from urllib.request import urlopen
from http.server import ThreadingHTTPServer
from server import Handler


class MockHttpTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.base = "http://127.0.0.1:" + str(cls.server.server_port)

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join()

    def get(self, path):
        with urlopen(self.base + path, timeout=3) as response:
            return json.load(response)

    def test_search_and_empty_result(self):
        self.assertEqual(self.get('/shop/of/name?name=' + quote('阅读'))['data'][0]['id'], 1)
        self.assertEqual(self.get('/shop/of/name?name=missing')['data'], [])

    def test_detail_and_missing(self):
        self.assertEqual(self.get('/shop/1')['data']['name'], '城市阅读空间')
        self.assertFalse(self.get('/shop/999')['success'])

    def test_vouchers_and_empty(self):
        self.assertEqual(self.get('/voucher/list/1')['data'][0]['id'], 101)
        self.assertEqual(self.get('/voucher/list/3')['data'], [])
        self.assertFalse(self.get('/voucher/list/999')['success'])

    def test_unknown_endpoint(self):
        with self.assertRaises(HTTPError) as result:
            self.get('/unknown')
        self.assertEqual(result.exception.code, 404)


if __name__ == '__main__':
    unittest.main()
