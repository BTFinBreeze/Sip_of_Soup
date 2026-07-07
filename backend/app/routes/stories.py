from flask import Blueprint, request, jsonify
from sqlalchemy.orm import Session
import json
from app.models.story import Story
from app.config.database import get_db

stories_bp = Blueprint('stories', __name__)

@stories_bp.route('/stories', methods=['GET'])
def get_stories():
    """获取故事列表（支持筛选）"""
    db: Session = next(get_db())
    try:
        tag = request.args.get('tag')
        difficulty = request.args.get('difficulty')
        
        query = db.query(Story)
        
        if tag:
            query = query.filter(Story.tags.contains(tag))
        if difficulty:
            query = query.filter(Story.difficulty == difficulty)
        
        stories = query.all()
        
        result = []
        for story in stories:
            try:
                tags = json.loads(story.tags) if story.tags else []
            except:
                tags = []
            try:
                keywords = json.loads(story.keywords) if story.keywords else []
            except:
                keywords = []
                
            result.append({
                'id': story.id,
                'title': story.title,
                'surface': story.surface,
                'truth': story.truth,
                'tags': tags,
                'difficulty': story.difficulty,
                'keywords': keywords
            })
        
        return jsonify(result)
    except Exception as e:
        import traceback
        traceback.print_exc()
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
        
        try:
            tags = json.loads(story.tags) if story.tags else []
        except:
            tags = []
        try:
            keywords = json.loads(story.keywords) if story.keywords else []
        except:
            keywords = []
        
        return jsonify({
            'id': story.id,
            'title': story.title,
            'surface': story.surface,
            'truth': story.truth,
            'tags': tags,
            'difficulty': story.difficulty,
            'keywords': keywords
        })
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()

@stories_bp.route('/stories', methods=['POST'])
def create_story():
    """创建新故事"""
    db: Session = next(get_db())
    try:
        data = request.json
        
        required_fields = ['title', 'surface', 'truth', 'tags', 'difficulty', 'keywords']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'缺少字段: {field}'}), 400
        
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
            'tags': data['tags'],
            'difficulty': story.difficulty,
            'keywords': data['keywords']
        }), 201
    except Exception as e:
        db.rollback()
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()

@stories_bp.route('/stories/<int:id>', methods=['PUT'])
def update_story(id):
    """更新故事"""
    db: Session = next(get_db())
    try:
        story = db.query(Story).filter(Story.id == id).first()
        if not story:
            return jsonify({'error': '故事不存在'}), 404
        
        data = request.json
        
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
        
        try:
            tags = json.loads(story.tags) if story.tags else []
        except:
            tags = []
        try:
            keywords = json.loads(story.keywords) if story.keywords else []
        except:
            keywords = []
        
        return jsonify({
            'id': story.id,
            'title': story.title,
            'surface': story.surface,
            'truth': story.truth,
            'tags': tags,
            'difficulty': story.difficulty,
            'keywords': keywords
        })
    except Exception as e:
        db.rollback()
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()

@stories_bp.route('/stories/<int:id>', methods=['DELETE'])
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
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()
