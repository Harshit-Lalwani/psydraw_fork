import argparse
import json
import os
from dotenv import load_dotenv

from langchain_google_genai import ChatGoogleGenerativeAI

from src.model_langchain import HTPModel

TEXT_MODEL = "gemini-2.5-flash"
MULTIMODAL_MODEL = "gemini-2.5-flash"

def get_args():
    parser = argparse.ArgumentParser(description="HTP Model")
    parser.add_argument("--image_file", type=str, help="Path to the image")
    parser.add_argument("--save_path", type=str, help="Path to save the result")
    parser.add_argument("--language", type=str, default="en", help="Language of the analysis report")
    
    return parser.parse_args()

load_dotenv()
config = get_args()

assert config.language == "en", "Language should be 'en' (English only)."

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
    language=config.language,
    use_cache=True
)

result = model.workflow(
    image_path=config.image_file,
    language=config.language
)

# save the result to a file
with open(config.save_path, "w") as f:
    f.write(json.dumps(result, indent=4, ensure_ascii=False))