from pydantic import BaseModel
from typing import Generic, TypeVar, List, Optional, Any

T = TypeVar("T")

class BaseResponse(BaseModel, Generic[T]):
    code: int = 1
    msg: str = "操作成功"
    result: List[T] = []

    @classmethod
    def success(cls, result: List[T], msg: str = "操作成功"):
        return cls(code=1, msg=msg, result=result)

    @classmethod
    def error(cls, msg: str = "操作失败", code: int = 0):
        return cls(code=code, msg=msg, result=[])
