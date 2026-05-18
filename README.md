# 海龟汤游戏 (Turtle Soup Game)

一款基于智谱AI的海龟汤推理游戏，包含前端游戏界面、后端API服务和管理员面板。

## 项目结构

```
Turtle_soup/
├── backend/                 # 后端服务 (Flask)
│   ├── app/                 # 应用核心代码
│   │   ├── config/          # 配置文件
│   │   ├── routes/          # API路由
│   │   ├── models/          # 数据库模型
│   │   └── services/        # 业务服务
│   ├── .env                 # 环境变量配置
│   └── requirements.txt     # Python依赖
├── frontend/                # 前端游戏界面 (Flutter)
│   └── lib/                 # Dart源码
├── admin_panel/             # 管理员面板 (Flutter)
│   └── lib/                 # Dart源码
└── README.md               # 项目说明文档
```

## 技术栈

### 后端
- **框架**: Flask 2.x
- **数据库**: MySQL / SQLite
- **ORM**: SQLAlchemy
- **AI服务**: 智谱AI (glm-4-flash)

### 前端
- **框架**: Flutter 3.x
- **状态管理**: Provider
- **路由**: GoRouter

## 环境要求

### 后端
- Python 3.10+
- MySQL 8.0+ 或 SQLite 3.x
- 智谱AI API Key

### 前端
- Flutter 3.10+
- Dart 3.0+
- Android Studio / Xcode (可选，用于原生构建)

## 快速开始

### 1. 配置后端环境

```bash
# 进入后端目录
cd backend

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件，配置数据库连接和API密钥
```

### 2. 配置 .env 文件

```env
# 数据库配置
DATABASE_URL=mysql+pymysql://username:password@localhost:3306/turtle_soup
# 或使用 SQLite
# DATABASE_URL=sqlite:///./turtle_soup.db

# 智谱AI配置
ZHIPU_API_KEY=your_api_key_here
ZHIPU_MODEL=glm-4-flash

# 服务配置
FLASK_APP=app
FLASK_ENV=development
PORT=5000
```

### 3. 启动后端服务

```bash
cd backend
python run.py
```

服务将在 http://localhost:5000 启动

### 4. 启动前端

```bash
# 游戏前端
cd frontend
flutter run

# 管理员面板
cd admin_panel
flutter run
```

## API 接口

### 故事相关

| 接口 | 方法 | 描述 |
|------|------|------|
| `/stories` | GET | 获取故事列表 |
| `/stories/<id>` | GET | 获取单个故事详情 |
| `/stories` | POST | 创建新故事 |
| `/stories/<id>` | PUT | 更新故事 |
| `/stories/<id>` | DELETE | 删除故事 |

### 游戏相关

| 接口 | 方法 | 描述 |
|------|------|------|
| `/game/start` | POST | 开始游戏 |
| `/game/ask` | POST | 提交问题 |
| `/game/hint` | POST | 获取提示 |
| `/game/end` | POST | 结束游戏 |

### 管理员相关

| 接口 | 方法 | 描述 |
|------|------|------|
| `/admin/login` | POST | 管理员登录 |
| `/admin/stories` | GET | 获取所有故事（管理） |
| `/admin/stories` | POST | 创建故事（管理） |

## 数据库结构

### stories 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键，自增 |
| title | VARCHAR(100) | 故事标题 |
| surface | TEXT | 故事谜面 |
| truth | TEXT | 故事汤底 |
| tags | TEXT | 标签（清汤/红汤） |
| difficulty | VARCHAR(20) | 难度等级 |
| keywords | TEXT | 关键词（JSON） |
| created_at | DATETIME | 创建时间 |

### game_records 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | VARCHAR(36) | UUID主键 |
| user_id | VARCHAR(100) | 用户ID |
| story_id | INT | 故事ID |
| questions_used | INT | 使用问题数 |
| hints_used | INT | 使用提示数 |
| result | VARCHAR(20) | 游戏结果 |
| time_used | INT | 用时（秒） |
| created_at | DATETIME | 创建时间 |

## 管理员账号

默认管理员账号：
- **用户名**: admin
- **密码**: admin123

> 建议在生产环境中修改默认密码

## 游戏规则

1. 玩家根据故事谜面进行提问
2. 系统只能回答「是」、「否」、「无关」或「正确」
3. 玩家通过提问逐步推理出故事真相
4. 当玩家猜中核心真相时，游戏结束

## 开发说明

### 添加新故事

通过管理员面板或直接调用 API 添加故事，需包含：
- 标题
- 谜面（表面故事）
- 汤底（真实故事）
- 标签（清汤/红汤）
- 难度（简单/中等/困难）
- 关键词（用于提示）
- 结束判定点（用于判断游戏结束）

### AI 配置

项目使用智谱AI的 glm-4-flash 模型进行回答判断，需要配置有效的 API Key。

## 部署

### 生产环境部署

```bash
# 使用 Gunicorn 运行后端
pip install gunicorn
gunicorn -w 4 app:app

# 前端构建
cd frontend
flutter build web
```

### Docker 部署（可选）

可根据需要创建 Dockerfile 和 docker-compose.yml

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！