from pydantic import BaseModel
from typing import Generic, TypeVar, Union, List, Any

T = TypeVar("T")

class BaseResponse(BaseModel, Generic[T]):
    code: int = 1
    msg: str = "操作成功"
    # 修改点：result 可以是单个对象 T，也可以是对象列表 List[T]
    result: Union[T, List[T], None] = None

    @classmethod
    def success(cls, result: Any, msg: str = "操作成功"):
        return cls(code=1, msg=msg, result=result)

    @classmethod
    def error(cls, msg: str = "操作失败", code: int = 0):
        return cls(code=code, msg=msg, result=None)
