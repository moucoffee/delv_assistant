import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from agents.lawyer_agent import chat_with_agent_sync
import langchain

print("LangChain 版本:", langchain.__version__)


def test_text_upload():
    print("\n=== 测试 1: 文本材料上传 ===")
    response = chat_with_agent_sync(
        "帮我给案件ID为1的案件上传一份文本材料，材料名称是'案情说明.txt'，"
        "类别是案件材料，文件内容是：'本案是张三故意伤害案，当事人张三与李四因纠纷发生肢体冲突...'"
    )
    print("Agent 回复:", response)


def test_image_upload():
    print("\n=== 测试 2: 图片材料上传 ===")
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    uploads_dir = os.path.join(BASE_DIR, "uploads")
    
    if not os.path.exists(uploads_dir):
        print("uploads 目录不存在")
        return
    
    files = os.listdir(uploads_dir)
    if not files:
        print("没有找到测试文件")
        return
    
    test_file = files[0]
    file_path = os.path.join(uploads_dir, test_file)
    file_size = os.path.getsize(file_path)
    
    print(f"使用测试文件: {test_file}, 大小: {file_size} 字节")
    
    response = chat_with_agent_sync(
        f"帮我给案件ID为1的案件上传一份图片材料，材料名称是'现场照片.png'，"
        f"类别是举证材料，文件地址是'/uploads/{test_file}'，文件类型是png，文件大小是{file_size}B"
    )
    print("Agent 回复:", response)


def test_another_image_upload():
    print("\n=== 测试 3: 另一张图片上传 ===")
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    uploads_dir = os.path.join(BASE_DIR, "uploads")
    
    files = os.listdir(uploads_dir)
    if len(files) < 2:
        print("文件数量不足")
        return
    
    test_file = files[1]
    file_path = os.path.join(uploads_dir, test_file)
    file_size = os.path.getsize(file_path)
    
    print(f"使用测试文件: {test_file}, 大小: {file_size} 字节")
    
    response = chat_with_agent_sync(
        f"帮我给案件ID为1的案件上传一份图片材料，材料名称是'证据材料.png'，"
        f"类别是举证材料，文件地址是'/uploads/{test_file}'，文件类型是png，文件大小是{file_size}B"
    )
    print("Agent 回复:", response)


def check_material_list():
    print("\n=== 检查材料列表 ===")
    response = chat_with_agent_sync("帮我查看一下案件ID为1的所有材料列表")
    print("Agent 回复:", response)


if __name__ == "__main__":
    test_text_upload()
    test_image_upload()
    test_another_image_upload()
    check_material_list()
