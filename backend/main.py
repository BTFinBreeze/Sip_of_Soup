from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from app.config.database import engine, Base
from app.models.story import Story
from app.models.game_record import GameRecord
from app.models.user import User
from app.routes.stories import stories_bp
from app.routes.game import game_bp
from app.routes.admin import admin_bp

# 创建数据库表
Base.metadata.create_all(bind=engine)

# 创建Flask应用
app = Flask(__name__)

# 配置JWT
app.config['JWT_SECRET_KEY'] = 'your-secret-key-here-keep-it-secret'
jwt = JWTManager(app)

# 启用CORS
CORS(app)

# 注册路由
app.register_blueprint(stories_bp, url_prefix='/api')
app.register_blueprint(game_bp, url_prefix='/api')
app.register_blueprint(admin_bp, url_prefix='/api/admin')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
