import requests
import json
import re
import os
from dotenv import load_dotenv

class AIService:
    def __init__(self):
        load_dotenv()
        self.base_url = "https://open.bigmodel.cn/api/paas/v4"
        self.api_url = f"{self.base_url}/chat/completions"
        self.api_key = os.getenv("ZHIPU_API_KEY", "")
        self.model = os.getenv("ZHIPU_MODEL", "glm-4-flash")
        
        if not self.api_key:
            raise ValueError("ZHIPU_API_KEY environment variable is not set")
    
    def get_answer(self, question, story_truth, ending_points="", history=""):
        if not self.api_key:
            return "错误：未配置API密钥"
            
        try:
            template = """你是一个海龟汤游戏主持人。你需要根据【汤底】、【结束判定点】、【历史问答记录】和【当前用户输入】判断该如何回答。

【汤底】
{soup_answer}

【结束判定点】
{ending_points}

【历史问答记录】
{history}

【当前用户输入】
{user_question}

【输出限制】
你只能输出以下四个词之一：
是
否
无关
正确

不得输出解释、标点、空格或其他任何内容。

【基本回答规则】
1. 当前用户输入与汤底一致，但只是局部确认，回答：是。
2. 当前用户输入与汤底矛盾，回答：否。
3. 当前用户输入与汤底主线无关，或无法根据汤底判断，回答：无关。
4. 当前用户输入已经基本还原汤底核心真相，回答：正确。

【“正确”的判定规则】
你需要判断用户是否已经可以结束游戏。

不要求用户逐字复述汤底。
不要求用户说出所有细节。
不要求用户的表达顺序与汤底一致。
只要用户表达的语义与汤底核心真相基本一致，就应回答：正确。

当用户覆盖【结束判定点】中的大部分关键点，并且没有重大错误时，回答：正确。

【大部分关键点的含义】
如果【结束判定点】有 4 个，用户猜中其中 3 个左右，并且剩余内容不是核心反转，可以回答：正确。
如果【结束判定点】有 5 个，用户猜中其中 4 个左右，可以回答：正确。
如果用户虽然没有逐条覆盖，但已经把事件、原因和结局的核心逻辑说清楚，也可以回答：正确。

【重大错误的含义】
如果用户的说法会改变汤底核心含义，则不能回答“正确”。
例如：
- 把凶手、死者、原因、反转、因果关系说反；
- 把意外说成谋杀，或把谋杀说成意外；
- 把关键误会、身份关系、动机理解错。

【重要提醒】
“正确”表示用户已经基本猜出汤底，可以结束游戏。
不要因为用户没有说出所有细节就继续回答“是”。
如果用户已经猜出核心真相，必须回答“正确”。"""
            
            user_prompt = template.format(
                soup_answer=story_truth,
                ending_points=ending_points,
                history=history,
                user_question=question
            )
            
            headers = {
                "Content-Type": "application/json",
                "Authorization": f"Bearer {self.api_key}"
            }
            
            payload = {
                "model": self.model,
                "messages": [
                    {"role": "user", "content": user_prompt}
                ],
                "temperature": 0.1
            }
            
            response = requests.post(
                self.api_url,
                headers=headers,
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get("choices"):
                    answer = data["choices"][0]["message"]["content"].strip()
                    return self._normalize_answer(answer)
                return "AI响应格式错误"
            else:
                error_msg = f"请求失败: {response.status_code}"
                try:
                    error_data = response.json()
                    error_msg = error_data["error"].get("message", str(error_data))
                except:
                    pass
                return f"API错误：{error_msg}"
        except Exception as e:
            return f"服务异常：{str(e)}"
    
    def _normalize_answer(self, answer):
        answer = answer.strip()
        if "是" in answer: return "是"
        if "否" in answer: return "否"
        if "无关" in answer: return "无关"
        if "正确" in answer: return "正确"
        match = re.search(r'(是|否|无关|正确)', answer)
        return match.group(1) if match else "无关"