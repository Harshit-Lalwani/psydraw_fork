import os

import uvicorn
from langchain_google_genai import ChatGoogleGenerativeAI

from src.app.api import create_app
from src.model_langchain import HTPModel
import argparse

def get_parse():
    parser = argparse.ArgumentParser(description="HTP Model")
    parser.add_argument("--port", type=int, default=9557, help="Port number")
    
    return parser.parse_args()


TEXT_MODEL = "gemini-2.5-flash"
MULTIMODAL_MODEL = "gemini-2.5-flash"

text_model = ChatGoogleGenerativeAI(
    model=TEXT_MODEL,
    temperature=0.2,
    google_api_key=os.getenv("GOOGLE_API_KEY"),
)
multimodal_model = ChatGoogleGenerativeAI(
    model=MULTIMODAL_MODEL,
    temperature=0.2,
    google_api_key=os.getenv("GOOGLE_API_KEY"),
)

model = HTPModel(
    text_model=text_model,
    multimodal_model=multimodal_model,
    language="zh",
    use_cache=True
)

config = get_parse()

app = create_app(model)
uvicorn.run(app, host="127.0.0.1", port=config.port, log_level="info")