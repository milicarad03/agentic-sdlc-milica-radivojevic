# Python 3.12 environment
FROM python:3.12-slim

# Working directory inside the container
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Run automated tests by default
CMD ["pytest", "tests/", "-v", "--tb=short"]
