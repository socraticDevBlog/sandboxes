![Version](https://img.shields.io/endpoint?url=https://20260302version-random-api-endpoint.azurewebsites.net/version)

# version-to-markdown

we want to display the version of our app running in production in our GitHub
project `README.md` file

our app just need to have an API endpoint that returns such a json response:

```json
content={
    "schemaVersion": 1,
    "label": "version",
    "message": version,
    "color": "blue"
    },
headers={
    "Cache-Control": "no-store, no-cache, must-revalidate",
    "Pragma": "no-cache"
    }
```

simple markdown cannot make api calls

we need a third-party service like <shields.io>

## provision the proof-of-concept api to Azure

```bash
chmod +x azure.sh
```
