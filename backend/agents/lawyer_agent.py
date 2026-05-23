from langchain.chat_models import init_chat_model
from langchain.agents import create_agent
from langchain_core.runnables import RunnableConfig
from langchain.agents.middleware import SummarizationMiddleware
from langgraph.checkpoint.memory import MemorySaver
from dotenv import load_dotenv
import os
from agents.tools.case_tool import (
    get_case_detail_tool,
    update_case_tool,
)
from agents.tools.material_tool import (
    upload_material_tool,
    get_material_list_tool,
    create_text_material_tool,
)

load_dotenv()

api_key = os.getenv("DASHSCOPE_API_KEY")
base_url = os.getenv("DASHSCOPE_BASE_URL")

model = init_chat_model(
    model="qwen-max",
    model_provider="openai",
    api_key=api_key,
    base_url=base_url,
)

tools = [
    get_case_detail_tool,
    update_case_tool,
    upload_material_tool,
    get_material_list_tool,
    create_text_material_tool,
]

checkpointer = MemorySaver()

summarization_model = init_chat_model(
    model="qwen-plus",
    model_provider="openai",
    api_key=api_key,
    base_url=base_url,
)

middleware = SummarizationMiddleware(
    model=summarization_model,
    trigger=("messages", 20),
    keep=("messages", 5),
)

agent = create_agent(
    model=model,
    tools=tools,
    system_prompt="你是一个专业的律师助手，只服务于案件详情页面。你的职责包括：\n\n1. 查看和修改当前案件的详情\n2. 上传材料到当前案件（包括图片、文件、文本等）\n3. 根据用户需求，生成文本材料（如起诉状、答辩状、证据清单等），并保存到对应分类\n4. 查看当前案件的材料列表\n\n你只能使用提供的工具，不要做超出案件详情页面范围的操作。如果用户没有指定材料分类，根据材料内容自动选择合适的分类：\n- 案件材料：案情说明、案件背景等\n- 举证材料：证据、照片、文件等\n- 文书材料：起诉状、答辩状、申请书等\n- 其他材料：不属于上述分类的材料",
    middleware=[middleware],
    checkpointer=checkpointer,
)


async def chat_with_agent(input_text: str, user_id: int = 1):
    config: RunnableConfig = {
        "configurable": {
            "thread_id": str(user_id),
        }
    }
    
    result = await agent.ainvoke(
        {"messages": [("user", input_text)]},
        config=config,
    )
    return result["messages"][-1].content


async def chat_with_agent_stream(input_text: str, user_id: int = 1):
    config: RunnableConfig = {
        "configurable": {
            "thread_id": str(user_id),
        }
    }
    
    async for chunk in agent.astream(
        {"messages": [("user", input_text)]},
        config=config,
    ):
        if "messages" in chunk:
            for msg in chunk["messages"]:
                if hasattr(msg, "content") and msg.content:
                    yield msg.content
