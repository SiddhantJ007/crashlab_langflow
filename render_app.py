from langflow.main import setup_app


def create_app():
    return setup_app(backend_only=True)
