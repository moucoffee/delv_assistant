from fastapi import APIRouter, UploadFile, File
from fastapi.staticfiles import StaticFiles
import os
from schemas.base import BaseResponse
import uuid

router = APIRouter(prefix="/upload", tags=["文件上传"])

UPLOAD_DIR = "uploads"

# 确保文件夹存在
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("", response_model=BaseResponse)
async def upload_file(file: UploadFile = File(...)):
    file_content = await file.read()
   
    file_extension = file.filename.split(".")[-1] if "." in file.filename else ""
    safe_filename = f"{uuid.uuid4()}.{file_extension}"
    
    file_path = os.path.join(UPLOAD_DIR, safe_filename)
    with open(file_path, "wb") as buffer:
        buffer.write(file_content)
    
    #相对路径！
    file_url = f"/uploads/{safe_filename}"
    
    return BaseResponse.success(result={"file_url": file_url, "filename": file.filename})
