from fastapi.testclient import TestClient
from main import app


class MyTestCase(unittest.TestCase):

    client = TestClient(app)

    def test_get_bot_score():
        response = client.post("/bot-score", json={"feature1": 0.5, "feature2": 0.1})
        assert response.status_code == 200
        assert "p_bot" in response.json()


if __name__ == '__main__':
    test_get_bot_score.main()



