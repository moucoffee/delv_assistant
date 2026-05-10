from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from routers import user, case, material, upload
from config.database import engine, Base
from models import user as user_model, case as case_model, material as material_model

Base.metadata.create_all(bind=engine)

app = FastAPI(title="AI Assistant Backend")

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # 允许所有来源，开发环境可以这样设置
    allow_credentials=True,
    allow_methods=["*"], # 允许所有方法
    allow_headers=["*"], # 允许所有请求头
)

# 包含模块路由
app.include_router(user.router)
app.include_router(case.router)
app.include_router(material.router)
app.include_router(upload.router)

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
