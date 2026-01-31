from loguru import logger as LOGGER
import sys
import os

log_level = os.getenv("LOG_LEVEL", "INFO")
LOGGER.remove()
LOGGER.add(sys.stderr, level=log_level)
LOGGER.info(f"Logging level set to {log_level}")
