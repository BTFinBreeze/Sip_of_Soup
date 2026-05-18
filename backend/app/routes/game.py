from flask import Blueprint, request, jsonify
from sqlalchemy.orm import Session
import json
import uuid
from app.models.story import Story
from app.models.game_record import GameRecord
from app.config.database import get_db
from app.services.ai_service import AIService

# 创建AI服务实例
ai_service = AIService()

game_bp = Blueprint('game', __name__)

@game_bp.route('/game/start', methods=['POST'])
def start_game():
    """开始游戏"""
    db: Session = next(get_db())
    try:
        data = request.json
        soup_type = data.get('soup_type')  # 清汤或红汤
        difficulty = data.get('difficulty')  # 简单/中等/困难
        
        # 验证参数
        if not soup_type or not difficulty:
            return jsonify({'error': '缺少汤类型或难度参数'}), 400
        
        # 筛选故事
        query = db.query(Story).filter(
            Story.tags.contains(soup_type),
            Story.difficulty == difficulty
        )
        
        story = query.first()
        if not story:
            return jsonify({'error': '该类型暂无故事'}), 404
        
        # 返回故事信息
        return jsonify({
            'id': story.id,
            'title': story.title,
            'surface': story.surface,
            'difficulty': story.difficulty
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()

@game_bp.route('/game/ask', methods=['POST'])
def ask_question():
    """提交问题"""
    try:
        data = request.json
        story_id = data.get('story_id')
        question = data.get('question')
        history = data.get('history', '')
        ending_points = data.get('ending_points', '')
        
        # 验证参数
        if not story_id or not question:
            return jsonify({'error': '缺少故事ID或问题'}), 400
        
        # 获取故事
        db: Session = next(get_db())
        story = db.query(Story).filter(Story.id == story_id).first()
        if not story:
            return jsonify({'error': '故事不存在'}), 404
        
        # 获取AI回答（包含对话记忆）
        answer = ai_service.get_answer(question, story.truth, ending_points, history)
        
        return jsonify({'answer': answer})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if 'db' in locals():
            db.close()

@game_bp.route('/game/hint', methods=['POST'])
def get_hint():
    """获取提示"""
    try:
        data = request.json
        story_id = data.get('story_id')
        hint_index = data.get('hint_index', 0)  # 提示索引（0-2）
        
        # 验证参数
        if not story_id:
            return jsonify({'error': '缺少故事ID'}), 400
        
        # 获取故事
        db: Session = next(get_db())
        story = db.query(Story).filter(Story.id == story_id).first()
        if not story:
            return jsonify({'error': '故事不存在'}), 404
        
        # 解析关键词
        keywords = json.loads(story.keywords)
        
        # 生成提示
        if hint_index == 0:
            hint = f'提示1: 故事与{keywords[0]}有关'
        elif hint_index == 1:
            hint = f'提示2: 注意{keywords[1]}这个细节'
        else:
            hint = f'提示3: 关键线索是{keywords[2]}'
        
        return jsonify({'hint': hint})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if 'db' in locals():
            db.close()

@game_bp.route('/game/end', methods=['POST'])
def end_game():
    """结束游戏"""
    db: Session = next(get_db())
    try:
        data = request.json
        user_id = data.get('user_id', 'anonymous')  # 暂时用匿名ID
        story_id = data.get('story_id')
        questions_used = data.get('questions_used', 0)
        hints_used = data.get('hints_used', 0)
        result = data.get('result')  # 胜利/失败/放弃
        time_used = data.get('time_used', 0)  # 游戏时长（秒）
        
        # 验证参数
        if not story_id or not result:
            return jsonify({'error': '缺少故事ID或结果'}), 400
        
        # 创建游戏记录
        record = GameRecord(
            id=str(uuid.uuid4()),
            user_id=user_id,
            story_id=story_id,
            questions_used=questions_used,
            hints_used=hints_used,
            result=result,
            time_used=time_used
        )
        
        db.add(record)
        db.commit()
        
        return jsonify({'message': '游戏记录保存成功'})
    except Exception as e:
        db.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()
