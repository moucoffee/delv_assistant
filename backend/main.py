from fastapi import FastAPI
from routers import user, case
from config.database import engine, Base
from models import user as user_model, case as case_model

# 创建数据库表
Base.metadata.create_all(bind=engine)

app = FastAPI(title="AI Assistant Backend")

# 包含模块路由
app.include_router(user.router)
app.include_router(case.router)

@app.get("/")
async def root():
    return {
        "code": 1,
        "msg": "AI Assistant Backend is running",
        "result": []
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
