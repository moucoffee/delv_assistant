from config.database import SessionLocal, engine, Base
from models.user import User
from models.case import Case
from utils.auth import get_password_hash

def init_db():
    # 创建所有表
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    # 检查是否已经有数据
    if db.query(User).first():
        print("数据库已存在数据，跳过初始化。")
        db.close()
        return

    # 创建测试用户
    user1 = User(
        username="张律师",
        phone="13800138000",
        password_hash=get_password_hash("123456"),
        avatar="https://api.dicebear.com/7.x/avataaars/svg?seed=Zhang",
        coins=500,
        trial_days=30
    )
    user2 = User(
        username="李律师",
        phone="13900139000",
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
    print("测试账号 1: 手机号: 13800138000, 密码: 123456")
    print("测试账号 2: 手机号: 13900139000, 密码: 123456")
    db.close()

if __name__ == "__main__":
    init_db()
