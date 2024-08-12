from dataclasses import dataclass
from typing import Mapping, Self, TypeVar, override, Generic
from enum import StrEnum

from dataclasses_json import DataClassJsonMixin
from dataclasses_json.mm import SchemaType
from jrpc.data import ParsedJson
from marshmallow import ValidationError
from result import Result, Ok, Err
from jrpc import client as jrpc_client
from jrpc.data import JsonRpcError

from .errors import MuxApiError, ResponseSchemaMismatch


class MuxMethodName(StrEnum):
    GET_MULTIPLE = "mux.get-multiple"
    GET_ALL = "mux.get-all"
    RESOLVE_MULTIPLE = "mux.resolve-multiple"
    RESOLVE_ALL = "mux.resolve-all"
    SET_MULTIPLE = "mux.set-multiple"
    CLEAR_AND_REPLACE = "mux.clear-and-replace"
    LOCATION_INFO = "mux.location-info"


T = TypeVar("T")


def _try_load(
    schema_class: type[T], schema: SchemaType[T], parsed_json: ParsedJson
) -> Result[T, str]:
    if not isinstance(parsed_json, Mapping):
        return Err(
            f"Failed to load {schema_class.__name__} from schema: 'parsed_json' must be a dict"
        )
    if not isinstance(parsed_json, dict):
        parsed_json = dict(parsed_json)

    try:
        return Ok(schema.load(parsed_json, unknown="exclude"))
    except ValidationError as error:
        return Err(f"Failed to load {schema_class.__name__} from schema: {error}")


class JsonTryLoadMixin(DataClassJsonMixin):
    """
    Mixin built on dataclasses-json that adds a try_load method
    """

    @classmethod
    def try_load(cls, parsed_json: ParsedJson) -> Result[Self, str]:
        return _try_load(cls, cls.schema(), parsed_json)


TParams = TypeVar("TParams", bound=DataClassJsonMixin)
TResult = TypeVar("TResult", bound=DataClassJsonMixin)


class _MuxRequestHandler(
    Generic[TParams, TResult], jrpc_client.RequestHandler[TResult, MuxApiError]
):
    _result_type: type[TResult]

    def __init__(
        self, method: MuxMethodName, params: TParams, result_type: type[TResult]
    ) -> None:
        super().__init__(method.value, params.to_dict())
        self._result_type = result_type

    @override
    def load_result(self, result: ParsedJson) -> Result[TResult, MuxApiError]:
        match _try_load(self._result_type, self._result_type.schema(), result):
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


class GetMultiple(_MuxRequestHandler[GetMultipleParams, GetMultipleResult]):
    def __init__(self, params: GetMultipleParams) -> None:
        super().__init__(MuxMethodName.GET_MULTIPLE, params, GetMultipleResult)


@dataclass
class GetAllParams(JsonTryLoadMixin):
    location: str
    namespace: str


@dataclass
class GetAllResult(JsonTryLoadMixin):
    values: dict[str, str]


class GetAll(_MuxRequestHandler[GetAllParams, GetAllResult]):
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


class ResolveMultiple(_MuxRequestHandler[ResolveMultipleParams, ResolveMultipleResult]):
    def __init__(self, params: ResolveMultipleParams) -> None:
        super().__init__(MuxMethodName.RESOLVE_MULTIPLE, params, ResolveMultipleResult)


@dataclass
class ResolveAllParams(JsonTryLoadMixin):
    location: str
    namespace: str


@dataclass
class ResolveAllResult(JsonTryLoadMixin):
    values: dict[str, str]


class ResolveAll(_MuxRequestHandler[ResolveAllParams, ResolveAllResult]):
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


class SetMultiple(_MuxRequestHandler[SetMultipleParams, SetMultipleResult]):
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


class ClearAndReplace(_MuxRequestHandler[ClearAndReplaceParams, ClearAndReplaceResult]):
    def __init__(self, params: ClearAndReplaceParams) -> None:
        super().__init__(MuxMethodName.CLEAR_AND_REPLACE, params, ClearAndReplaceResult)


@dataclass
class LocationInfoParams(JsonTryLoadMixin):
    ref: str


@dataclass
class LocationInfoResult(JsonTryLoadMixin):
    exists: bool
    id: str | None


class LocationInfo(_MuxRequestHandler[LocationInfoParams, LocationInfoResult]):
    def __init__(self, params: LocationInfoParams) -> None:
        super().__init__(MuxMethodName.LOCATION_INFO, params, LocationInfoResult)
