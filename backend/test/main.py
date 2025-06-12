from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import asyncpg
import uvicorn
from datetime import datetime, timedelta
import asyncio

app = FastAPI()

@app.get("/send_signal/{lamp_name}")
async def send_signal(lamp_name: str):
    print("начало")
    await asyncio.sleep(10)
    print("конец")
    return {"test": lamp_name}
    
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9999)
