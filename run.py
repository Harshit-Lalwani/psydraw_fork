import argparse
import json
import os
from dotenv import load_dotenv

from langchain_google_genai import ChatGoogleGenerativeAI

from src.model_langchain import HTPModel
from src.report_generator import create_docx_report # <--- IMPORT THE NEW FUNCTION

TEXT_MODEL = "gemini-2.5-flash"
MULTIMODAL_MODEL = "gemini-2.5-flash"

def get_args():
    parser = argparse.ArgumentParser(description="HTP Model")
    parser.add_argument("--image_file", type=str, help="Path to the image")
    parser.add_argument("--save_path", type=str, help="Path to save the result (will be used as base name for .json and .docx)")
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

result = model.pluto_workflow( # Using your specialized workflow
    image_path=config.image_file,
    language=config.language
)

# --- NEW REPORTING LOGIC ---
if config.save_path:
    # Define paths for both JSON and DOCX files
    base_save_path = os.path.splitext(config.save_path)[0]
    json_save_path = base_save_path + ".json"
    docx_save_path = base_save_path + ".docx"

    # 1. Save the raw JSON result
    with open(json_save_path, "w") as f:
        f.write(json.dumps(result, indent=4, ensure_ascii=False))
    print(f"JSON analysis saved to: {json_save_path}")

    # 2. Generate and save the professional DOCX report
    create_docx_report(
        image_path=config.image_file,
        analysis_json=result,
        save_path=docx_save_path
    )
else:
    # If no save path is provided, just print the JSON to the console
    print(json.dumps(result, indent=4, ensure_ascii=False))