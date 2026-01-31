# UMe Feasibility Study

Synthetic data generation and analysis for validating the UMe matchmaking concept.

## Setup

Create a `.env` file:
```bash
OPENAI_API_KEY=sk-your-openai-api-key-here
APP_PASSWORD=your-secure-password-here
```

Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

Run the Streamlit app:
```bash
streamlit run app.py
```

The app generates synthetic user profiles and tests the matchmaking algorithm.

## Files

- `app.py` - Main Streamlit application
- `utils.py` - Helper functions for LLM interactions
- `users.json` - Generated synthetic user profiles
- `personas.json` - Distilled personality summaries
- `matches.json` - Generated match results
- `analyse.ipynb` - Jupyter notebook for analyzing results
