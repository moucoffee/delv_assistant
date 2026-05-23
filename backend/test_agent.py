import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from agents.lawyer_agent import chat_with_agent_sync

def test_persistence():
    print("\n=== 测试 1: 第一次对话 ===")
    response1 = chat_with_agent_sync("你好，我叫张三")
    print("Agent 回复:", response1)
    
    print("\n=== 测试 2: 第二次对话（应该记得用户名字） ===")
    response2 = chat_with_agent_sync("我叫什么名字？")
    print("Agent 回复:", response2)
    
    print("\n=== 测试 3: 查看案件列表 ===")
    response3 = chat_with_agent_sync("帮我查看一下案件列表")
    print("Agent 回复:", response3)


if __name__ == "__main__":
    test_persistence()
