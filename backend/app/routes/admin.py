from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from sqlalchemy.orm import Session
import json
from app.models.story import Story
from app.config.database import get_db

admin_bp = Blueprint('admin', __name__)

ADMIN_CREDENTIALS = {
    'username': 'admin',
    'password': 'admin123'
}

@admin_bp.route('/login', methods=['POST'])
def login():
    print('=== Login request received ===')
    data = request.get_json()
    print(f'Received data: {data}')
    username = data.get('username')
    password = data.get('password')
    
    print(f'Username: {username}, Password: {password}')
    print(f'Expected: {ADMIN_CREDENTIALS["username"]}, {ADMIN_CREDENTIALS["password"]}')
    
    if username == ADMIN_CREDENTIALS['username'] and password == ADMIN_CREDENTIALS['password']:
        print('Login successful')
        access_token = create_access_token(identity=username)
        return jsonify({'token': access_token}), 200
    else:
        print('Login failed')
        return jsonify({'message': '账号或密码错误'}), 401

@admin_bp.route('/stories', methods=['GET'])
@jwt_required()
def get_all_stories():
    db: Session = next(get_db())
    try:
        stories = db.query(Story).all()
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
        return jsonify(result), 200
    finally:
        db.close()

@admin_bp.route('/stories', methods=['POST'])
@jwt_required()
def create_story():
    db: Session = next(get_db())
    try:
        data = request.get_json()
        
        new_story = Story(
            title=data['title'],
            surface=data['surface'],
            truth=data['truth'],
            tags=json.dumps(data['tags'], ensure_ascii=False),
            difficulty=data['difficulty'],
            keywords=json.dumps(data['keywords'], ensure_ascii=False)
        )
        
        db.add(new_story)
        db.commit()
        db.refresh(new_story)
        
        return jsonify({
            'id': new_story.id,
            'title': new_story.title
        }), 201
    except Exception as e:
        db.rollback()
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()

@admin_bp.route('/stories/<int:story_id>', methods=['PUT'])
@jwt_required()
def update_story(story_id):
    db: Session = next(get_db())
    try:
        story = db.query(Story).filter(Story.id == story_id).first()
        if not story:
            return jsonify({'message': '故事不存在'}), 404
        
        data = request.get_json()
        
        story.title = data.get('title', story.title)
        story.surface = data.get('surface', story.surface)
        story.truth = data.get('truth', story.truth)
        story.tags = json.dumps(data.get('tags', []), ensure_ascii=False)
        story.difficulty = data.get('difficulty', story.difficulty)
        story.keywords = json.dumps(data.get('keywords', []), ensure_ascii=False)
        
        db.commit()
        db.refresh(story)
        
        return jsonify({'message': '更新成功'}), 200
    except Exception as e:
        db.rollback()
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()

@admin_bp.route('/stories/<int:story_id>', methods=['DELETE'])
@jwt_required()
def delete_story(story_id):
    db: Session = next(get_db())
    try:
        story = db.query(Story).filter(Story.id == story_id).first()
        if not story:
            return jsonify({'message': '故事不存在'}), 404
        
        db.delete(story)
        db.commit()
        
        return jsonify({'message': '删除成功'}), 200
    except Exception as e:
        db.rollback()
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close()
