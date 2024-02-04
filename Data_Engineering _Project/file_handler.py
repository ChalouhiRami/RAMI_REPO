import json

def read_config(config_file):
    try:
        with open(config_file, "r") as file:
            config_data = json.load(file)
        return config_data
    except FileNotFoundError:
        print(f"Configuration file '{config_file}' not found.")
        return None
    except Exception as error:
        print(f"An error occurred while reading the configuration file: {str(error)}")
        return None
