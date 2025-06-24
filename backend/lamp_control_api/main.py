from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel
import psycopg2
import uvicorn

app = FastAPI()

# Database configuration
DB_CONFIG = {
    "dbname": "lampdb",
    "host": "postgres_backend",
    "user": "postgres",
    "password": "sqlMaxSql",
    "port": "5432"
}

# Establish database connection
connection = psycopg2.connect(**DB_CONFIG)
connection.autocommit = True

class LampData(BaseModel):
    lamp_name: str
    target_lamp_name: str

# 201 - ok
# 409 - lamp name is create
# 500 - exception
@app.get("/register_lamp/{lamp_name}", status_code=status.HTTP_201_CREATED)
def register_lamp(lamp_name: str):
    cursor = connection.cursor()
    try:
        cursor.execute(
            "INSERT INTO lamps (lamp_name, last_check, is_active) VALUES (%s, CURRENT_TIMESTAMP, TRUE) RETURNING id",
            (lamp_name,)
        )
        lamp_id = cursor.fetchone()[0]
        return {"message": f"Lamp {lamp_name} registered successfully", "lamp_id": lamp_id}
    except psycopg2.IntegrityError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Lamp {lamp_name} already exists"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )
    finally:
        cursor.close()

# 200 - ok
# 210 - lamp not found
# 211 - connection not found
# 500 - exception
@app.get("/check_status/{lamp_name}", status_code=status.HTTP_200_OK)
def check_status(lamp_name: str):
    cursor = connection.cursor()
    try:
        # Get lamp ID
        cursor.execute(
            "SELECT id FROM lamps WHERE lamp_name = %s", 
            (lamp_name,)
        )
        lamp_result = cursor.fetchone()
        
        if not lamp_result:
            raise HTTPException(
                status_code=210,
                detail="Lamp not found"
            )
        
        lamp_id = lamp_result[0]

        # Check for connection
        cursor.execute(
            "SELECT id FROM lamp_connections WHERE target_lamp_id = %s", 
            (lamp_id,)
        )
        connection_result = cursor.fetchone()

        if not connection_result:
            
            raise HTTPException(
                status_code=211,
                detail="No connection found for this lamp"
            )

        connection_id = connection_result[0]

        # Check for unread messages
        cursor.execute(
            """SELECT id FROM messages 
            WHERE lamp_connection_id = %s AND is_read = FALSE 
            ORDER BY id DESC LIMIT 1""",
            (connection_id,)
        )
        message_result = cursor.fetchone()

        if message_result:
            # Mark message as read
            cursor.execute(
                "UPDATE messages SET is_read = TRUE WHERE id = %s",
                (message_result[0],)
            )
            # Update last check time
            cursor.execute(
                "UPDATE lamps SET last_check = CURRENT_TIMESTAMP WHERE id = %s",
                (lamp_id,)
            )
            return "1"

        # Update last check time
        cursor.execute(
            "UPDATE lamps SET last_check = CURRENT_TIMESTAMP WHERE id = %s",
            (lamp_id,)
        )
        return "0"

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )
    finally:
        cursor.close()

# 200 - ok
# 210 - lamp not found
# 211 - connection not found
# 500 - exception
@app.get("/send_signal/{lamp_name}", status_code=status.HTTP_200_OK)
def send_signal(lamp_name: str):
    cursor = connection.cursor()
    try:
        # Get lamp ID
        cursor.execute(
            "SELECT id FROM lamps WHERE lamp_name = %s", 
            (lamp_name,)
        )
        lamp_result = cursor.fetchone()

        if not lamp_result:
            raise HTTPException(
                status_code=210,
                detail="Lamp not found"
            )

        lamp_id = lamp_result[0]

        # Check for connection
        cursor.execute(
            "SELECT id FROM lamp_connections WHERE lamp_id = %s",
            (lamp_id,)
        )
        connection_result = cursor.fetchone()

        if not connection_result:
            raise HTTPException(
                status_code=211,
                detail="No connection found between the lamps"
            )

        connection_id = connection_result[0]

        # Insert message
        cursor.execute(
            """INSERT INTO messages 
            (lamp_connection_id, is_read, message_content) 
            VALUES (%s, %s, %s)""",
            (connection_id, False, "Signal sent from lamp to target")
        )
        
        return {"message": "Signal sent successfully"}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )
    finally:
        cursor.close()

# 201 - ok
# 210 - lamp name is create
# 211 - Lamps are already connected 
# 500 - exception
@app.get("/connect_lamps/{lamp_name}/{target_lamp_name}", status_code=status.HTTP_201_CREATED)
def connect_lamps(lamp_name: str, target_lamp_name:str):
    cursor = connection.cursor()
    try:
        # Get lamp IDs
        cursor.execute(
            "SELECT id FROM lamps WHERE lamp_name = %s", 
            (lamp_name,)
        )
        lamp_result = cursor.fetchone()

        cursor.execute(
            "SELECT id FROM lamps WHERE lamp_name = %s", 
            (target_lamp_name,)
        )
        target_lamp_result = cursor.fetchone()

        if not lamp_result or not target_lamp_result:
            raise HTTPException(
                status_code=210,
                detail="One or both lamps not found"
            )

        lamp_id = lamp_result[0]
        target_lamp_id = target_lamp_result[0]

        cursor.execute(
            """DELETE FROM lamp_connections 
            WHERE lamp_id = %s OR target_lamp_id = %s
            OR lamp_id = %s OR target_lamp_id = %s""",
            (lamp_id, lamp_id, target_lamp_id, target_lamp_id)
        )

        # Check if connection already exists
        cursor.execute(
            """SELECT id FROM lamp_connections 
            WHERE lamp_id = %s AND target_lamp_id = %s""",
            (lamp_id, target_lamp_id)
        )
        if cursor.fetchone():
            raise HTTPException(
                status_code=211,
                detail="Lamps are already connected"
            )

        # Create bidirectional connection
        cursor.execute(
            """INSERT INTO lamp_connections 
            (lamp_id, target_lamp_id) VALUES (%s, %s)""",
            (lamp_id, target_lamp_id)
        )
        cursor.execute(
            """INSERT INTO lamp_connections 
            (lamp_id, target_lamp_id) VALUES (%s, %s)""",
            (target_lamp_id, lamp_id)
        )

        return {"message": "Lamps connected successfully"}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )
    finally:
        cursor.close()

@app.on_event("shutdown")
def shutdown_db_connection():
    if connection:
        connection.close()

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9999)

