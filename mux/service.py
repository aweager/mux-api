from abc import ABC, abstractmethod

from result import Result

from .api import (
    ClearAndReplaceParams,
    ClearAndReplaceResult,
    GetAllParams,
    GetAllResult,
    GetMultipleParams,
    GetMultipleResult,
    LocationInfoParams,
    LocationInfoResult,
    ResolveAllParams,
    ResolveAllResult,
    ResolveMultipleParams,
    ResolveMultipleResult,
    SetMultipleParams,
    SetMultipleResult,
)
from .errors import MuxApiError


class MuxApi(ABC):
    @abstractmethod
    async def get_multiple(
        self, params: GetMultipleParams
    ) -> Result[GetMultipleResult, MuxApiError]:
        pass

    @abstractmethod
    async def get_all(self, params: GetAllParams) -> Result[GetAllResult, MuxApiError]:
        pass

    @abstractmethod
    async def resolve_multiple(
        self, params: ResolveMultipleParams
    ) -> Result[ResolveMultipleResult, MuxApiError]:
        pass

    @abstractmethod
    async def resolve_all(self, params: ResolveAllParams) -> Result[ResolveAllResult, MuxApiError]:
        pass

    @abstractmethod
    async def set_multiple(
        self, params: SetMultipleParams
    ) -> Result[SetMultipleResult, MuxApiError]:
        pass

    @abstractmethod
    async def clear_and_replace(
        self, params: ClearAndReplaceParams
    ) -> Result[ClearAndReplaceResult, MuxApiError]:
        pass

    @abstractmethod
    async def get_location_info(
        self, params: LocationInfoParams
    ) -> Result[LocationInfoResult, MuxApiError]:
        pass
