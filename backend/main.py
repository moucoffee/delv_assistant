from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.security import HTTPBearer
from routers import user, case, material, upload
from config.database import engine, Base, SessionLocal
from models import user as user_model, case as case_model, material as material_model
from models.user import User
from models.case import Case
from utils.auth import get_password_hash

def init_db_data():
    """初始化数据库数据"""
    db = SessionLocal()
    
    try:
        if db.query(User).first():
            print("数据库已存在数据，跳过初始化。")
            return
        
        # 创建测试用户
        user1 = User(
            username="张律师",
            phone="15215913177",
            password_hash=get_password_hash("123456"),
            avatar="https://api.dicebear.com/7.x/avataaars/svg?seed=Zhang",
            coins=500,
            trial_days=30
        )
        user2 = User(
            username="李律师",
            phone="18257757875",
            password_hash=get_password_hash("123456"),
            avatar="https://api.dicebear.com/7.x/avataaars/svg?seed=Li",
            coins=200,
            trial_days=15
        )
        
        db.add(user1)
        db.add(user2)
        db.commit()
        db.refresh(user1)
        db.refresh(user2)

        # 为用户1创建案件
        case1 = Case(
            user_id=user1.id,
            case_type="刑事案件",
            status="新建",
            title="张三故意伤害案",
            parties="张三",
            phone="13811112222",
            amount=100000.0,
            description="这是一起由于邻里纠纷引发的伤害案件。",
            material_count=5,
            total_file_size="15.2MB"
        )
        case2 = Case(
            user_id=user1.id,
            case_type="民事案件",
            status="办理中",
            title="王五房屋租赁纠纷",
            parties="王五",
            phone="13933334444",
            amount=5000.0,
            description="房东王五与租客之间的押金退还纠纷。",
            material_count=3,
            total_file_size="2.5MB"
        )
        
        db.add(case1)
        db.add(case2)
        db.commit()
        
        print("数据库初始化完成！已创建测试用户和案件。")
        print("测试账号 1: 手机号: 15215913177, 密码: 123456")
        print("测试账号 2: 手机号: 18257757875, 密码: 123456")
    finally:
        db.close()

Base.metadata.create_all(bind=engine)
init_db_data()

app = FastAPI(
    title="AI Assistant Backend",
    swagger_ui_parameters={"persistAuthorization": True},
)

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
