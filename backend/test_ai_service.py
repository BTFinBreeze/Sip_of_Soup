import sys
import os

# 添加项目根目录到Python路径
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.services.ai_service import AIService

# 创建 AIService 实例
ai_service = AIService()

# 测试用例1: 正常问题
print("测试用例1: 正常问题")
question1 = "图书馆5楼是被封起来了吗？"
story_truth1 = "图书馆曾经有5楼，但因为一场火灾导致多人死亡，后来被封了，但电梯按钮没有拆除。"
answer1 = ai_service.get_answer(question1, story_truth1)
print(f"问题: {question1}")
print(f"汤底: {story_truth1}")
print(f"回答: {answer1}")
print()

# 测试用例2: 猜测关键剧情
print("测试用例2: 猜测关键剧情")
question2 = "是不是因为曾经有谋杀案件导致5楼被封了？"
story_truth2 = "图书馆曾经有5楼，但因为一场火灾导致多人死亡，后来被封了，但电梯按钮没有拆除。"
answer2 = ai_service.get_answer(question2, story_truth2)
print(f"问题: {question2}")
print(f"汤底: {story_truth2}")
print(f"回答: {answer2}")
print()

# 测试用例3: 无关问题
print("测试用例3: 无关问题")
question3 = "今天天气怎么样？"
story_truth3 = "图书馆曾经有5楼，但因为一场火灾导致多人死亡，后来被封了，但电梯按钮没有拆除。"
answer3 = ai_service.get_answer(question3, story_truth3)
print(f"问题: {question3}")
print(f"汤底: {story_truth3}")
print(f"回答: {answer3}")
print()

# 测试用例4: 另一个故事
print("测试用例4: 另一个故事")
question4 = "男人是不是吃过人肉？"
story_truth4 = "男人曾遇难漂流吃过人肉汤，后来发现餐厅汤不是人肉，于是意识到自己曾经吃的是人肉。"
answer4 = ai_service.get_answer(question4, story_truth4)
print(f"问题: {question4}")
print(f"汤底: {story_truth4}")
print(f"回答: {answer4}")
