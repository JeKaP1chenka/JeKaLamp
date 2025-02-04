from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import asyncpg
import uvicorn
from datetime import datetime, timedelta

app = FastAPI()

DATABASE_URL = "postgresql://postgres:sqlMaxSql@postgres:5432/lampdb"

# Глобальное подключение
db_connection = None

# Создание подключения при запуске приложения
@app.on_event("startup")
async def startup():
    global db_connection
    db_connection = await asyncpg.connect(DATABASE_URL)

# Закрытие подключения при завершении работы приложения
@app.on_event("shutdown")
async def shutdown():
    global db_connection
    if db_connection:
        await db_connection.close()

class LampData(BaseModel):
    lamp_name: str
    target_lamp_name: str

@app.post("/register_lamp/{lamp_name}")
async def register_lamp(lamp_name: str):
    global db_connection
    try:
        # Вставляем данные о лампе в базу данных
        result = await db_connection.fetchrow(
            "INSERT INTO lamps (lamp_name, last_check, is_active) VALUES ($1, CURRENT_TIMESTAMP, TRUE) RETURNING id",
            lamp_name
        )
        lamp_id = result['id']
        return {"message": f"Lamp {lamp_name} registered successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/check_status/{lamp_name}")
async def check_status(lamp_name: str):
    global db_connection
    try:
        # Получаем id лампы по имени
        lamp_result = await db_connection.fetchrow(
            "SELECT id FROM lamps WHERE lamp_name = $1", lamp_name
        )
        if lamp_result:
            lamp_id = lamp_result['id']

            # Проверяем, есть ли связь с другой лампой
            connection_result = await db_connection.fetchrow(
                "SELECT id FROM lamp_connections WHERE target_lamp_id = $1", lamp_id
            )

            if connection_result:
                # Проверяем наличие сообщений для данной лампы
                message_result = await db_connection.fetchrow(
                    "SELECT id FROM messages WHERE lamp_connection_id = $1 AND is_read = FALSE",
                    connection_result['id']
                )

                if message_result:
                    await db_connection.execute(
                        "UPDATE messages SET is_read = TRUE WHERE id = $1", message_result['id']
                    )
                    # Если есть сообщение, которое было отправлено с другой лампы
                    return True

                # Лампа активна, обновляем время последней проверки
                await db_connection.execute(
                    "UPDATE lamps SET last_check = CURRENT_TIMESTAMP WHERE id = $1", lamp_id
                )
                return False

            else:
                raise HTTPException(status_code=404, detail="No connection found for this lamp")
        else:
            raise HTTPException(status_code=404, detail="Lamp not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/send_signal/{lamp_name}")
async def send_signal(lamp_name: str):
    global db_connection
    try:
        # Находим id лампы по имени
        lamp_result = await db_connection.fetchrow(
            "SELECT id FROM lamps WHERE lamp_name = $1", lamp_name
        )

        if lamp_result:
            lamp_id = lamp_result['id']

            # Проверяем, есть ли связь между лампами
            connection_result = await db_connection.fetchrow(
                "SELECT id FROM lamp_connections WHERE lamp_id = $1",
                lamp_id
            )

            if connection_result:
                connection_id = connection_result['id']
                # Сигнал активен, добавляем сообщение
                await db_connection.execute(
                    "INSERT INTO messages (lamp_connection_id, is_read, message_content) VALUES ($1, $2, $3)",
                    connection_id, False, "Signal sent from lamp to target"
                )
                return {"message": "Signal sent successfully"}
            else:
                raise HTTPException(status_code=404, detail="No connection found between the lamps")
        else:
            raise HTTPException(status_code=404, detail="Lamp not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/connect_lamps/")
async def connect_lamps(lamp_data: LampData):
    global db_connection
    try:
        # Получаем id лампы и целевой лампы по их именам
        lamp_result = await db_connection.fetchrow(
            "SELECT id FROM lamps WHERE lamp_name = $1", lamp_data.lamp_name
        )
        target_lamp_result = await db_connection.fetchrow(
            "SELECT id FROM lamps WHERE lamp_name = $1", lamp_data.target_lamp_name
        )

        if lamp_result and target_lamp_result:
            lamp_id = lamp_result['id']
            target_lamp_id = target_lamp_result['id']

            # Проверяем, существует ли уже связь между этими лампами
            existing_connection = await db_connection.fetchrow(
                "SELECT id FROM lamp_connections WHERE lamp_id = $1 AND target_lamp_id = $2",
                lamp_id, target_lamp_id
            )
            if existing_connection:
                raise HTTPException(status_code=400, detail="Lamps are already connected")

            # Создаем двустороннюю связь между лампами
            await db_connection.execute(
                "INSERT INTO lamp_connections (lamp_id, target_lamp_id) VALUES ($1, $2)",
                lamp_id, target_lamp_id
            )
            await db_connection.execute(
                "INSERT INTO lamp_connections (lamp_id, target_lamp_id) VALUES ($1, $2)",
                target_lamp_id, lamp_id
            )

            return {"message": "Lamps connected successfully"}
        else:
            raise HTTPException(status_code=404, detail="One or both lamps not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9999)
