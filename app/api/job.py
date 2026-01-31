"""A background job to do matchmaking for all users"""

# Set environment variables
import dotenv

dotenv.load_dotenv()

# Import and run the matchmaking function
from src.algo import matchmaking  # noqa

response = matchmaking()

# Print the response
print(response)
