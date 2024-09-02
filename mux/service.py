from abc import ABC, abstractmethod

from jrpc.service import MethodSet, implements, make_method_set
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
    MuxMethod,
    ResolveAllParams,
    ResolveAllResult,
    ResolveMultipleParams,
    ResolveMultipleResult,
    SetMultipleParams,
    SetMultipleResult,
)
from .errors import MuxApiError


class MuxApi(ABC):
    @implements(MuxMethod.GET_MULTIPLE)
    @abstractmethod
    async def get_multiple(
        self, params: GetMultipleParams
    ) -> Result[GetMultipleResult, MuxApiError]:
        pass

    @implements(MuxMethod.GET_ALL)
    @abstractmethod
    async def get_all(self, params: GetAllParams) -> Result[GetAllResult, MuxApiError]:
        pass

    @implements(MuxMethod.RESOLVE_MULTIPLE)
    @abstractmethod
    async def resolve_multiple(
        self, params: ResolveMultipleParams
    ) -> Result[ResolveMultipleResult, MuxApiError]:
        pass

    @implements(MuxMethod.RESOLVE_ALL)
    @abstractmethod
    async def resolve_all(self, params: ResolveAllParams) -> Result[ResolveAllResult, MuxApiError]:
        pass

    @implements(MuxMethod.SET_MULTIPLE)
    @abstractmethod
    async def set_multiple(
        self, params: SetMultipleParams
    ) -> Result[SetMultipleResult, MuxApiError]:
        pass

    @implements(MuxMethod.CLEAR_AND_REPLACE)
    @abstractmethod
    async def clear_and_replace(
        self, params: ClearAndReplaceParams
    ) -> Result[ClearAndReplaceResult, MuxApiError]:
        pass

    @implements(MuxMethod.LOCATION_INFO)
    @abstractmethod
    async def get_location_info(
        self, params: LocationInfoParams
    ) -> Result[LocationInfoResult, MuxApiError]:
        pass

    def method_set(self) -> MethodSet:
        return make_method_set(MuxApi, self)
