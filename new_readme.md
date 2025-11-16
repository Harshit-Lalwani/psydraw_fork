# PsyDraw - HTP Analysis Tool

## Quick Start: Direct Inference

### Prerequisites
- Python 3.8+
- Google API key (free tier available)

### Setup

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure API key:**
   Create a `.env` file in the project root:
   ```
   GOOGLE_API_KEY=your_google_api_key_here
   ```
   Or set the environment variable:
   ```bash
   export GOOGLE_API_KEY=your_google_api_key_here
   ```

### Run Analysis

**Analyze a single HTP drawing:**
```bash
python run.py --image_file path/to/image.jpg --save_path output.json --language en
```

**Parameters:**
- `--image_file`: Path to HTP drawing image (JPG/PNG)
- `--save_path`: Output JSON file path (optional, prints to console if not provided)
- `--language`: `en` (English only, default: en)

### Output

Analysis results saved as JSON containing:
- **feature**: Observable drawing characteristics for each element (House, Tree, Person)
- **analysis**: Psychological interpretation of each element
- **merge**: Integrated cross-element analysis
- **final**: Professional assessment report
- **signal**: Mental health indicators
- **classification**: Binary assessment result (True = concerns detected)
- **usage**: Token consumption statistics

### Example

```bash
python run.py --image_file example/example1.jpg --save_path result.json --language en
```

Check `example/` folder for sample outputs.

---

**Note:** This tool is designed for clinical screening purposes only. Results should be reviewed by qualified mental health professionals.
