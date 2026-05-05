import yaml
import sys

try:
    with open('.github/workflows/deploy.yml', 'r') as f:
        yaml.safe_load(f)
    print('YAML syntax is valid')
    sys.exit(0)
except yaml.YAMLError as e:
    print(f'YAML syntax error: {e}')
    sys.exit(1)
except FileNotFoundError:
    print('File not found')
    sys.exit(1)
