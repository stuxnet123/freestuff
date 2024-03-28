#!/bin/bash

# Define the directory for the virtual environment
VENV_DIR="my_script_venv"

# Check for Python
echo "Checking for Python..."
if ! command -v python3 &>/dev/null; then
    echo "Python 3 not found. Please ensure Python 3 is installed."
    exit 1
fi

# Create a virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating a virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Ensure the 'requests' package is installed in the virtual environment
pip install requests

echo "" # Adding space for readability

# Python code starts here
PYTHON_CODE=$(cat <<'END_HEREDOC'
import requests

API_TOKEN = '8840378be0d8c407b69d3797aec2385f'
TAXJAR_API_URL = 'https://api.taxjar.com/v2/taxes'

def get_sales_tax(street, city, state, zip_code, country="US"):
    headers = {
        'Authorization': f'Bearer {API_TOKEN}',
        'Content-Type': 'application/json',
    }
    
    payload = {
        "from_country": country,
        "from_zip": zip_code,
        "from_state": state,
        "from_city": city,
        "from_street": street,
        "to_country": country,
        "to_zip": zip_code,
        "to_state": state,
        "to_city": city,
        "to_street": street,
        "amount": 100,
        "shipping": 0,
        "nexus_addresses": [{
            "id": "Main Location",
            "country": country,
            "zip": zip_code,
            "state": state,
            "city": city,
            "street": street,
        }],
        "line_items": [{
            "id": "1",
            "quantity": 1,
            "product_tax_code": "20010",
            "unit_price": 100,
            "discount": 0
        }]
    }
    
    response = requests.post(TAXJAR_API_URL, json=payload, headers=headers)
    
    if response.status_code == 200:
        tax_data = response.json()
        return tax_data
    else:
        print("Failed to retrieve data:", response.text)
        return None

def main():
    print("Enter the full address details separated by commas (street, city, state, zip):")
    address_input = input().strip()
    street, city, state, zip_code = address_input.split(', ')
    tax_data = get_sales_tax(street, city, state, zip_code)
    
    if tax_data:
        # Extracting the overall sales tax rate from the response
        total_tax_rate = tax_data['tax']['rate']
        print("") # Adding space before the result for readability
        print(f"Total sales tax rate for the address: {total_tax_rate*100}%")
    else:
        print("Could not retrieve sales tax rate.")

if __name__ == "__main__":
    main()
END_HEREDOC
)

# Execute the Python code
python3 -c "$PYTHON_CODE"

echo "" # Adding space after the script execution for readability

# Deactivate the virtual environment
deactivate