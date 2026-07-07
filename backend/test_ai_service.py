import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.services.ai_service import AIService

ai_service = AIService()

print("=" * 60)
print("海龟汤 AI 服务测试")
print("=" * 60)

# 测试1: 图书馆火灾故事 - 多轮对话测试
print("\n【测试1】图书馆火灾故事 - 多轮对话")
print("-" * 40)

story_truth = "图书馆曾经有5楼，但因为一场火灾导致多人死亡，后来被封了，但电梯按钮没有拆除。"
ending_points = """
1. 图书馆曾经有5楼
2. 5楼发生过火灾
3. 火灾导致多人死亡
4. 5楼后来被封了
5. 电梯按钮没有拆除
"""

history = ""
questions = [
    ("图书馆有5楼吗？", "是"),
    ("5楼现在还在吗？", "否"),
    ("5楼是被封起来了吗？", "是"),
    ("是因为火灾被封的吗？", "是"),
    ("火灾有人死亡吗？", "是"),
    ("是不是因为火灾导致多人死亡，所以5楼被封了，但电梯按钮没拆？", "正确"),
]

for i, (q, expected) in enumerate(questions):
    answer = ai_service.get_answer(q, story_truth, ending_points, history)
    status = "✓" if answer == expected else "✗"
    print(f"第{i+1}轮: 问题='{q}' → 回答='{answer}' (期望:'{expected}') {status}")
    if history:
        history += "\n"
    history += f"用户问: {q}\n主持人答: {answer}"

# 测试2: 海龟汤经典故事
print("\n【测试2】海龟汤经典故事 - 多轮对话")
print("-" * 40)

story_truth2 = "一个人走进餐厅点了海龟汤，喝了一口后崩溃自杀。真相是：他曾经遇难漂流，同伴骗他说吃的是海龟肉，其实吃的是死去同伴的肉。多年后他喝到真正的海龟汤，发现当年的味道不一样，意识到自己曾吃过人肉，于是自杀。"
ending_points2 = """
1. 男人以前遇过海难或生存危机
2. 他曾被迫吃下某种肉
3. 当时他以为吃的是海龟肉
4. 实际上吃的是人肉或同伴的肉
5. 现在真正的海龟汤味道不同，让他发现真相并自杀
"""

history2 = ""
questions2 = [
    ("他以前喝过海龟汤吗？", "是"),
    ("餐厅的海龟汤有毒吗？", "否"),
    ("他自杀是因为回忆吗？", "是"),
    ("当年有人骗了他吗？", "是"),
    ("当年他吃的是真的海龟肉吗？", "否"),
    ("当年他吃的是人肉吗？", "是"),
    ("他以前遇难时被骗吃的是同伴的肉，现在喝到真的海龟汤发现味道不一样，所以崩溃自杀了？", "正确"),
]

for i, (q, expected) in enumerate(questions2):
    answer = ai_service.get_answer(q, story_truth2, ending_points2, history2)
    status = "✓" if answer == expected else "✗"
    print(f"第{i+1}轮: 问题='{q}' → 回答='{answer}' (期望:'{expected}') {status}")
    if history2:
        history2 += "\n"
    history2 += f"用户问: {q}\n主持人答: {answer}"

# 测试3: 无关问题测试
print("\n【测试3】无关问题测试")
print("-" * 40)

irrelevant_questions = [
    ("今天天气怎么样？", story_truth, "无关"),
    ("图书馆有多少本书？", story_truth, "无关"),
    ("5楼的装修风格是什么？", story_truth, "无关"),
    ("火灾是几点发生的？", story_truth, "无关"),
]

for q, truth, expected in irrelevant_questions:
    answer = ai_service.get_answer(q, truth, ending_points, "")
    status = "✓" if answer == expected else "✗"
    print(f"问题='{q}' → 回答='{answer}' (期望:'{expected}') {status}")

# 测试4: 矛盾问题测试
print("\n【测试4】矛盾问题测试")
print("-" * 40)

contradiction_questions = [
    ("图书馆从来没有5楼吧？", story_truth, "否"),
    ("5楼是因为装修被封的吗？", story_truth, "否"),
    ("火灾没有人死亡吧？", story_truth, "否"),
    ("电梯按钮已经拆除了吧？", story_truth, "否"),
]

for q, truth, expected in contradiction_questions:
    answer = ai_service.get_answer(q, truth, ending_points, "")
    status = "✓" if answer == expected else "✗"
    print(f"问题='{q}' → 回答='{answer}' (期望:'{expected}') {status}")

# 测试5: 部分正确但未完全还原
print("\n【测试5】部分正确但未完全还原测试")
print("-" * 40)

partial_questions = [
    ("图书馆5楼被封了？", story_truth, "是"),
    ("是因为火灾吗？", story_truth, "是"),
    ("有人死亡吗？", story_truth, "是"),
]

for q, truth, expected in partial_questions:
    answer = ai_service.get_answer(q, truth, ending_points, "")
    status = "✓" if answer == expected else "✗"
    print(f"问题='{q}' → 回答='{answer}' (期望:'{expected}') {status}")

# 测试6: 错误猜测测试
print("\n【测试6】错误猜测测试")
print("-" * 40)

wrong_guesses = [
    ("是不是因为曾经有谋杀案件导致5楼被封了？", story_truth, "否"),
    ("火灾是人为纵火吗？", story_truth, "无关"),
    ("5楼是因为鬼魂被封的吗？", story_truth, "否"),
]

for q, truth, expected in wrong_guesses:
    answer = ai_service.get_answer(q, truth, ending_points, "")
    status = "✓" if answer == expected else "✗"
    print(f"问题='{q}' → 回答='{answer}' (期望:'{expected}') {status}")

# 测试7: 热气球故事
print("\n【测试7】热气球故事 - 多轮对话")
print("-" * 40)

story_truth3 = "男人在沙漠中死亡，身边有一根火柴。真相是：几个人乘坐热气球经过沙漠，热气球超重即将坠毁，大家抽火柴决定谁跳下去，男人抽到短火柴后跳下热气球死亡。"
ending_points3 = """
1. 男人是从热气球或高空交通工具上掉下去/跳下去的
2. 当时热气球超重或遇到危险
3. 大家通过抽火柴决定牺牲谁
4. 男人抽到了代表牺牲的火柴
5. 所以他死在沙漠中
"""

history3 = ""
questions3 = [
    ("男人是被谋杀的吗？", "否"),
    ("火柴和他的死亡有关吗？", "是"),
    ("他不是一个人在沙漠里旅行吗？", "是"),
    ("当时有其他人在场吗？", "是"),
    ("他是从高空掉下来的吗？", "是"),
    ("是不是他们坐热气球出事了，因为太重，所以抽火柴决定谁跳下去，结果他抽中了？", "正确"),
]

for i, (q, expected) in enumerate(questions3):
    answer = ai_service.get_answer(q, story_truth3, ending_points3, history3)
    status = "✓" if answer == expected else "✗"
    print(f"第{i+1}轮: 问题='{q}' → 回答='{answer}' (期望:'{expected}') {status}")
    if history3:
        history3 += "\n"
    history3 += f"用户问: {q}\n主持人答: {answer}"

print("\n" + "=" * 60)
print("测试完成")
print("=" * 60)