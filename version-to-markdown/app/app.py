import random
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()

@app.get("/version")
def get_version():
    version = f"{random.randint(0,10)}.{random.randint(0,20)}.{random.randint(0,100)}"
    return JSONResponse(
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
    )