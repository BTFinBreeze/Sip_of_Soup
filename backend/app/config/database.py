from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

# 数据库配置
DB_TYPE = os.getenv('DB_TYPE', 'sqlite')  # 默认为SQLite

if DB_TYPE == 'mysql':
    DB_USER = os.getenv('DB_USER', 'root')
    DB_PASSWORD = os.getenv('DB_PASSWORD', 'password')
    DB_HOST = os.getenv('DB_HOST', 'localhost')
    DB_PORT = os.getenv('DB_PORT', '3306')
    DB_NAME = os.getenv('DB_NAME', 'turtle_soup')
    DATABASE_URL = f'mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}?charset=utf8mb4'
else:
    # 使用SQLite作为备选方案
    DATABASE_URL = 'sqlite:///./turtle_soup.db'

print(f'使用数据库: {DATABASE_URL}')

# 创建数据库引擎
engine = create_engine(
    DATABASE_URL,
    connect_args={'check_same_thread': False} if DB_TYPE == 'sqlite' else {}
)

# 创建会话工厂
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 创建基类
Base = declarative_base()

# 依赖项：获取数据库会话
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
