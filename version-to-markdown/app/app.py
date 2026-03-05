import random
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()


@app.get("/dev/version")
def get_dev_version():
    version = f"{random.randint(0,10)}.{random.randint(0,20)}.{random.randint(0,100)}"
    return JSONResponse(
        content={
            "schemaVersion": 1,
            "label": "version in dev",
            "message": version,
            "color": "orange",
        },
        headers={
            "Cache-Control": "no-store, no-cache, must-revalidate",
            "Pragma": "no-cache",
        },
    )


@app.get("/staging/version")
def get_staging_version():
    version = f"{random.randint(0,10)}.{random.randint(0,20)}.{random.randint(0,100)}"
    return JSONResponse(
        content={
            "schemaVersion": 1,
            "label": "version in staging",
            "message": version,
            "color": "blue",
        },
        headers={
            "Cache-Control": "no-store, no-cache, must-revalidate",
            "Pragma": "no-cache",
        },
    )


@app.get("/prod/version")
def get_prod_version():
    version = f"{random.randint(0,10)}.{random.randint(0,20)}.{random.randint(0,100)}"
    return JSONResponse(
        content={
            "schemaVersion": 1,
            "label": "version in prod",
            "message": version,
            "color": "green",
        },
        headers={
            "Cache-Control": "no-store, no-cache, must-revalidate",
            "Pragma": "no-cache",
        },
    )
