from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import asyncpg
import uvicorn
from typing import Optional
from datetime import datetime, timedelta

app = FastAPI()

DATABASE_URL = "postgresql://postgres:sql@postgres:5432/lampdb"

# Для упрощения создадим подключение к базе данных
async def get_db_pool():
    return await asyncpg.create_pool(dsn=DATABASE_URL)

class LampData(BaseModel):
    lamp_name: str
    target_lamp_name: str

@app.post("/register_lamp/{lamp_name}")
async def register_lamp(lamp_name: str):
    pool = await get_db_pool()
    async with pool.acquire() as connection:
        # Вставляем данные о лампе в базу данных
        result = await connection.fetchrow(
            "INSERT INTO lamps (lamp_name, last_check, is_active) VALUES ($1, CURRENT_TIMESTAMP, TRUE) RETURNING id",
            lamp_name
        )
        lamp_id = result['id']
        return {"message": f"Lamp {lamp_name} registered successfully"}

@app.get("/check_status/{lamp_name}")
async def check_status(lamp_name: str):
    pool = await get_db_pool()
    async with pool.acquire() as connection:
        # Проверяем, существует ли связь с целевой лампой
        lamp_result = await connection.fetchrow(
            "SELECT id FROM lamps WHERE lamp_name = $1", lamp_name
        )
        if lamp_result:
            lamp_id = lamp_result['id']
            # Проверяем, есть ли связь с другими лампами
            connection_result = await connection.fetchrow(
                "SELECT id FROM lamp_connections WHERE lamp_id = $1", lamp_id
            )
            if connection_result:
                # Лампа активна, обновляем время последней проверки
                await connection.execute(
                    "UPDATE lamps SET last_check = CURRENT_TIMESTAMP WHERE id = $1", lamp_id
                )
                return {"message": "Lamp is active"}
            else:
                raise HTTPException(status_code=404, detail="No connection found for this lamp")
        else:
            raise HTTPException(status_code=404, detail="Lamp not found")

@app.post("/send_signal/")
async def send_signal(lamp_data: LampData):
    pool = await get_db_pool()
    async with pool.acquire() as connection:
        # Находим id лампы и целевой лампы по имени
        lamp_result = await connection.fetchrow(
            "SELECT id FROM lamps WHERE lamp_name = $1", lamp_data.lamp_name
        )
        target_lamp_result = await connection.fetchrow(
            "SELECT id FROM lamps WHERE lamp_name = $1", lamp_data.target_lamp_name
        )

        if lamp_result and target_lamp_result:
            lamp_id = lamp_result['id']
            target_lamp_id = target_lamp_result['id']

            # Проверяем, есть ли связь между лампами
            connection_result = await connection.fetchrow(
                "SELECT id FROM lamp_connections WHERE lamp_id = $1 AND target_lamp_id = $2",
                lamp_id, target_lamp_id
            )

            if connection_result:
                connection_id = connection_result['id']
                # Сигнал активен, добавляем сообщение
                await connection.execute(
                    "INSERT INTO messages (lamp_connection_id, is_from_lamp_to_target, message_content) VALUES ($1, $2, $3)",
                    connection_id, True, "Signal sent from lamp to target"
                )
                return {"message": "Signal sent successfully"}
            else:
                raise HTTPException(status_code=404, detail="No connection found between the lamps")
        else:
            raise HTTPException(status_code=404, detail="Lamp or target lamp not found")

@app.post("/connect_lamps/")
async def connect_lamps(lamp_data: LampData):
    pool = await get_db_pool()
    async with pool.acquire() as connection:
        # Получаем id лампы и целевой лампы по их именам
        lamp_result = await connection.fetchrow(
            "SELECT id FROM lamps WHERE lamp_name = $1", lamp_data.lamp_name
        )
        target_lamp_result = await connection.fetchrow(
            "SELECT id FROM lamps WHERE lamp_name = $1", lamp_data.target_lamp_name
        )

        if lamp_result and target_lamp_result:
            lamp_id = lamp_result['id']
            target_lamp_id = target_lamp_result['id']

            # Проверяем, существует ли уже связь между этими лампами
            existing_connection = await connection.fetchrow(
                "SELECT id FROM lamp_connections WHERE lamp_id = $1 AND target_lamp_id = $2",
                lamp_id, target_lamp_id
            )
            if existing_connection:
                raise HTTPException(status_code=400, detail="Lamps are already connected")

            # Создаем двустороннюю связь между лампами
            await connection.execute(
                "INSERT INTO lamp_connections (lamp_id, target_lamp_id) VALUES ($1, $2)",
                lamp_id, target_lamp_id
            )
            await connection.execute(
                "INSERT INTO lamp_connections (lamp_id, target_lamp_id) VALUES ($1, $2)",
                target_lamp_id, lamp_id
            )

            return {"message": "Lamps connected successfully"}
        else:
            raise HTTPException(status_code=404, detail="One or both lamps not found")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9999)
