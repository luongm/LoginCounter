import unittest
import json
from httplib import HTTPConnection

SERVER = "cryptic-wildwood-1008.herokuapp.com"

class RestTestCase(unittest.TestCase):
    """Super class for each scenario"""
    SUCCESS             =  1     #: a success
    ERR_BAD_CREDENTIALS = -1     #: (for login only) cannot find the user/password pair in the database
    ERR_USER_EXISTS     = -2     #: (for add only) trying to add a user that already exists
    ERR_BAD_USERNAME    = -3     #: (for add, or login) invalid user name (only empty string is invalid for now)
    ERR_BAD_PASSWORD    = -4     #: (for add only) invalid password (longer than 128 chars)

    def setUp(self):
        self.conn = HTTPConnection(SERVER, timeout=1)
        self.makeRequest("/TESTAPI/resetFixture")
        
    def makeRequest(self, url, method="POST", data={ }):
        """
        Make a request to the server.
        @param url is the relative url (no hostname)
        @param method is either "GET" or "POST"
        @param data is an optional dictionary of data to be send using JSON
        @result is a dictionary of key-value pairs
        """
        
        headers = { "Content-Type": "application/json", "Accept": "application/json" }
        body = json.dumps(data) if data != None else ""

        try:
            self.conn.request(method, url, body, headers)
        except Exception, e:
            if str(e).find("Connection refused") >= 0:
                print "Cannot connect to the server "+RestTestCase.serverToTest+". You should start the server first, or pass the proper TEST_SERVER environment variable"
                sys.exit(1)
            raise

        self.conn.sock.settimeout(100.0) # Give time to the remote server to start and respond
        resp = self.conn.getresponse()
        data_string = "<unknown"
        try:
            self.assertEquals(200, resp.status)
            data_string = resp.read()
            # The response must be a JSON request
            # Note: Python (at least) nicely tacks UTF8 information on this,
            #   we need to tease apart the two pieces.
            self.assertIsNotNone(resp.getheader('content-type'), "content-type header must be present in the response")
            self.assertTrue(resp.getheader('content-type').find('application/json') == 0, "content-type header must be application/json")

            data = json.loads(data_string)
            return data
        except:
            # In case of errors dump the whole response,to simplify debugging
            print "Got exception when processing response to url="+url+" method="+method+" data="+str(data)
            print "  Response status = "+str(resp.status)
            print "  Resonse headers: "
            for h, hv in resp.getheaders():
                print "    "+h+"  =  "+hv
            print "  Data string: "+data_string
            raise

    def assertResponse(self, response, errCode, count=None):
        expected = {'errCode': errCode}
        if count != None:
            expected['count'] = count
        self.assertDictEqual(expected, response)

    def tearDown(self):
        self.conn.close()

class TestAdd(RestTestCase):
    """When adding user(s)"""

    def test_should_get_SUCCESS_and_count_1_with_valid_username_and_valid_password(self):
        response = self.makeRequest("/users/add", data={'user':'c', 'password':'b'})
        self.assertResponse(response, RestTestCase.SUCCESS, 1)

    def test_should_get_ERR_BAD_PASSWORD_with_valid_username_and_invalid_password(self):
        response = self.makeRequest("/users/add", data={'user':'c', 'password':'b'*129})
        self.assertResponse(response, RestTestCase.ERR_BAD_PASSWORD)

    def test_should_get_ERR_BAD_USERNAME_with_invalid_username_and_valid_password(self):
        # case 1: empty username
        response = self.makeRequest("/users/add", data={'user':'', 'password':'b'})
        self.assertResponse(response, RestTestCase.ERR_BAD_USERNAME)

        # case 2: username longer than 128 chars
        response = self.makeRequest("/users/add", data={'user':'c'*129, 'password':'b'})
        self.assertResponse(response, RestTestCase.ERR_BAD_USERNAME)

    def test_should_get_ERR_USER_EXISTS_if_username_already_existed(self):
        response = self.makeRequest("/users/add", data={'user':'c', 'password':'b'})
        response = self.makeRequest("/users/add", data={'user':'c', 'password':'b'})
        self.assertResponse(response, RestTestCase.ERR_USER_EXISTS)

class TestLogin(RestTestCase):
    """When logging in"""

    def test_should_get_SUCCESS_and_count_incremented_if_valid_credentials(self):
        response = self.makeRequest("/users/add", data={'user':'c', 'password':'b'})
        for i in range(1,10):
            response = self.makeRequest("/users/login", data={'user':'c', 'password':'b'})
            self.assertResponse(response, RestTestCase.SUCCESS, count=i+1)

    def test_should_get_ERR_BAD_CREDENTIALS_and_count_incremented_if_invalid_credentials(self):
        # case 1: wrong password
        response = self.makeRequest("/users/add", data={'user':'c', 'password':'b'})
        response = self.makeRequest("/users/login", data={'user':'c', 'password':'d'})
        self.assertResponse(response, RestTestCase.ERR_BAD_CREDENTIALS)

        # case 2: nonexisting account
        response = self.makeRequest("/users/login", data={'user':'blah', 'password':'d'})

# if __name__ == "__main__":
#     unittest.main()
