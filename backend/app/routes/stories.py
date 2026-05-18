from flask import Blueprint, request, jsonify
from sqlalchemy.orm import Session
import json
from app.models.story import Story
from app.config.database import get_db
import uuid

stories_bp = Blueprint('stories', __name__)

@stories_bp.route('/stories', methods=['GET'])
def get_stories():
    """获取故事列表（支持筛选）"""
    db: Session = next(get_db())
    try:
        # 获取查询参数
        tag = request.args.get('tag')
        difficulty = request.args.get('difficulty')
        
        # 构建查询
        query = db.query(Story)
        
        # 筛选条件
        if tag:
            # 简单的标签筛选（实际项目中可能需要更复杂的JSON解析）
            query = query.filter(Story.tags.contains(tag))
        if difficulty:
            query = query.filter(Story.difficulty == difficulty)
        
        # 执行查询
        stories = query.all()
        
        # 格式化响应
        result = []
        for story in stories:
            result.append({
                'id': story.id,
                'title': story.title,
                'surface': story.surface,
                'truth': story.truth,
                'tags': json.loads(story.tags),
                'difficulty': story.difficulty,
                'keywords': json.loads(story.keywords)
            })
        
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()

@stories_bp.route('/stories/<int:id>', methods=['GET'])
def get_story(id):
    """获取单个故事"""
    db: Session = next(get_db())
    try:
        story = db.query(Story).filter(Story.id == id).first()
        if not story:
            return jsonify({'error': '故事不存在'}), 404
        
        return jsonify({
            'id': story.id,
            'title': story.title,
            'surface': story.surface,
            'truth': story.truth,
            'tags': json.loads(story.tags),
            'difficulty': story.difficulty,
            'keywords': json.loads(story.keywords)
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()

@stories_bp.route('/stories', methods=['POST'])
def create_story():
    """创建新故事"""
    db: Session = next(get_db())
    try:
        data = request.json
        
        # 验证数据
        required_fields = ['title', 'surface', 'truth', 'tags', 'difficulty', 'keywords']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'缺少字段: {field}'}), 400
        
        # 创建故事
        story = Story(
            title=data['title'],
            surface=data['surface'],
            truth=data['truth'],
            tags=json.dumps(data['tags'], ensure_ascii=False),
            difficulty=data['difficulty'],
            keywords=json.dumps(data['keywords'], ensure_ascii=False)
        )
        
        db.add(story)
        db.commit()
        db.refresh(story)
        
        return jsonify({
            'id': story.id,
            'title': story.title,
            'surface': story.surface,
            'truth': story.truth,
            'tags': json.loads(story.tags),
            'difficulty': story.difficulty,
            'keywords': json.loads(story.keywords)
        }), 201
    except Exception as e:
        db.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()

@stories_bp.route('/stories/<string:id>', methods=['PUT'])
def update_story(id):
    """更新故事"""
    db: Session = next(get_db())
    try:
        story = db.query(Story).filter(Story.id == id).first()
        if not story:
            return jsonify({'error': '故事不存在'}), 404
        
        data = request.json
        
        # 更新字段
        if 'title' in data:
            story.title = data['title']
        if 'surface' in data:
            story.surface = data['surface']
        if 'truth' in data:
            story.truth = data['truth']
        if 'tags' in data:
            story.tags = json.dumps(data['tags'])
        if 'difficulty' in data:
            story.difficulty = data['difficulty']
        if 'keywords' in data:
            story.keywords = json.dumps(data['keywords'])
        
        db.commit()
        db.refresh(story)
        
        return jsonify({
            'id': story.id,
            'title': story.title,
            'surface': story.surface,
            'truth': story.truth,
            'tags': json.loads(story.tags),
            'difficulty': story.difficulty,
            'keywords': json.loads(story.keywords)
        })
    except Exception as e:
        db.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()

@stories_bp.route('/stories/<string:id>', methods=['DELETE'])
def delete_story(id):
    """删除故事"""
    db: Session = next(get_db())
    try:
        story = db.query(Story).filter(Story.id == id).first()
        if not story:
            return jsonify({'error': '故事不存在'}), 404
        
        db.delete(story)
        db.commit()
        
        return jsonify({'message': '故事删除成功'})
    except Exception as e:
        db.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()
