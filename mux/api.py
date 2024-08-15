from dataclasses import dataclass
from typing import TypeVar, override, Generic
from enum import StrEnum

from jrpc.data import ParsedJson
from result import Result, Ok, Err
from jrpc import client as jrpc_client
from jrpc.data import JsonRpcError, JsonTryLoadMixin

from .errors import MuxApiError, ResponseSchemaMismatch


class MuxMethodName(StrEnum):
    GET_MULTIPLE = "mux.get-multiple"
    GET_ALL = "mux.get-all"
    RESOLVE_MULTIPLE = "mux.resolve-multiple"
    RESOLVE_ALL = "mux.resolve-all"
    SET_MULTIPLE = "mux.set-multiple"
    CLEAR_AND_REPLACE = "mux.clear-and-replace"
    LOCATION_INFO = "mux.location-info"


_TParams = TypeVar("_TParams", bound=JsonTryLoadMixin)
_TResult = TypeVar("_TResult", bound=JsonTryLoadMixin)


class _MuxRequestDefinition(
    Generic[_TParams, _TResult], jrpc_client.RequestDefinition[_TResult, MuxApiError]
):
    _result_type: type[_TResult]

    def __init__(
        self, method: MuxMethodName, params: _TParams, result_type: type[_TResult]
    ) -> None:
        super().__init__(method.value, params.to_dict())
        self._result_type = result_type

    @override
    def load_result(self, result: ParsedJson) -> Result[_TResult, MuxApiError]:
        match self._result_type.try_load(result):
            case Ok() as ok:
                return ok
            case Err(msg):
                return Err(
                    MuxApiError.from_data(
                        ResponseSchemaMismatch(self._result_type.__name__, msg)
                    )
                )

    @override
    def convert_error(self, error: JsonRpcError) -> MuxApiError:
        return MuxApiError.from_json_rpc_error(error)


@dataclass
class GetMultipleParams(JsonTryLoadMixin):
    location: str
    namespace: str
    keys: list[str]


@dataclass
class GetMultipleResult(JsonTryLoadMixin):
    values: dict[str, str | None]


class GetMultiple(_MuxRequestDefinition[GetMultipleParams, GetMultipleResult]):
    def __init__(self, params: GetMultipleParams) -> None:
        super().__init__(MuxMethodName.GET_MULTIPLE, params, GetMultipleResult)


@dataclass
class GetAllParams(JsonTryLoadMixin):
    location: str
    namespace: str


@dataclass
class GetAllResult(JsonTryLoadMixin):
    values: dict[str, str]


class GetAll(_MuxRequestDefinition[GetAllParams, GetAllResult]):
    def __init__(self, params: GetAllParams) -> None:
        super().__init__(
            MuxMethodName.GET_ALL,
            params,
            GetAllResult,
        )


@dataclass
class ResolveMultipleParams(JsonTryLoadMixin):
    location: str
    namespace: str
    keys: list[str]


@dataclass
class ResolveMultipleResult(JsonTryLoadMixin):
    values: dict[str, str | None]


class ResolveMultiple(
    _MuxRequestDefinition[ResolveMultipleParams, ResolveMultipleResult]
):
    def __init__(self, params: ResolveMultipleParams) -> None:
        super().__init__(MuxMethodName.RESOLVE_MULTIPLE, params, ResolveMultipleResult)


@dataclass
class ResolveAllParams(JsonTryLoadMixin):
    location: str
    namespace: str


@dataclass
class ResolveAllResult(JsonTryLoadMixin):
    values: dict[str, str]


class ResolveAll(_MuxRequestDefinition[ResolveAllParams, ResolveAllResult]):
    def __init__(self, params: ResolveAllParams) -> None:
        super().__init__(MuxMethodName.RESOLVE_ALL, params, ResolveAllResult)


@dataclass
class SetMultipleParams(JsonTryLoadMixin):
    location: str
    namespace: str
    values: dict[str, str | None]


@dataclass
class SetMultipleResult(JsonTryLoadMixin):
    pass


class SetMultiple(_MuxRequestDefinition[SetMultipleParams, SetMultipleResult]):
    def __init__(self, params: SetMultipleParams) -> None:
        super().__init__(MuxMethodName.SET_MULTIPLE, params, SetMultipleResult)


@dataclass
class ClearAndReplaceParams(JsonTryLoadMixin):
    location: str
    namespace: str
    values: dict[str, str]


@dataclass
class ClearAndReplaceResult(JsonTryLoadMixin):
    pass


class ClearAndReplace(
    _MuxRequestDefinition[ClearAndReplaceParams, ClearAndReplaceResult]
):
    def __init__(self, params: ClearAndReplaceParams) -> None:
        super().__init__(MuxMethodName.CLEAR_AND_REPLACE, params, ClearAndReplaceResult)


@dataclass
class LocationInfoParams(JsonTryLoadMixin):
    ref: str


@dataclass
class LocationInfoResult(JsonTryLoadMixin):
    exists: bool
    id: str | None


class LocationInfo(_MuxRequestDefinition[LocationInfoParams, LocationInfoResult]):
    def __init__(self, params: LocationInfoParams) -> None:
        super().__init__(MuxMethodName.LOCATION_INFO, params, LocationInfoResult)
