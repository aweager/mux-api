from dataclasses import dataclass

from jrpc.data import JsonTryLoadMixin
from jrpc.service import JsonTryConverter, MethodDescriptor

from .errors import ERROR_CONVERTER


@dataclass
class GetMultipleParams(JsonTryLoadMixin):
    location: str
    namespace: str
    keys: list[str]


@dataclass
class GetMultipleResult(JsonTryLoadMixin):
    values: dict[str, str | None]


@dataclass
class GetAllParams(JsonTryLoadMixin):
    location: str
    namespace: str


@dataclass
class GetAllResult(JsonTryLoadMixin):
    values: dict[str, str]


@dataclass
class ResolveMultipleParams(JsonTryLoadMixin):
    location: str
    namespace: str
    keys: list[str]


@dataclass
class ResolveMultipleResult(JsonTryLoadMixin):
    values: dict[str, str | None]


@dataclass
class ResolveAllParams(JsonTryLoadMixin):
    location: str
    namespace: str


@dataclass
class ResolveAllResult(JsonTryLoadMixin):
    values: dict[str, str]


@dataclass
class SetMultipleParams(JsonTryLoadMixin):
    location: str
    namespace: str
    values: dict[str, str | None]


@dataclass
class SetMultipleResult(JsonTryLoadMixin):
    pass


@dataclass
class ClearAndReplaceParams(JsonTryLoadMixin):
    location: str
    namespace: str
    values: dict[str, str]


@dataclass
class ClearAndReplaceResult(JsonTryLoadMixin):
    pass


@dataclass
class LocationInfoParams(JsonTryLoadMixin):
    ref: str


@dataclass
class LocationInfoResult(JsonTryLoadMixin):
    exists: bool
    id: str | None


class MuxMethod:
    GET_MULTIPLE = MethodDescriptor(
        name="mux.get-multiple",
        params_converter=JsonTryConverter(GetMultipleParams),
        result_converter=JsonTryConverter(GetMultipleResult),
        error_converter=ERROR_CONVERTER,
    )
    GET_ALL = MethodDescriptor(
        name="mux.get-all",
        params_converter=JsonTryConverter(GetAllParams),
        result_converter=JsonTryConverter(GetAllResult),
        error_converter=ERROR_CONVERTER,
    )
    RESOLVE_MULTIPLE = MethodDescriptor(
        name="mux.resolve-multiple",
        params_converter=JsonTryConverter(ResolveMultipleParams),
        result_converter=JsonTryConverter(ResolveMultipleResult),
        error_converter=ERROR_CONVERTER,
    )
    RESOLVE_ALL = MethodDescriptor(
        name="mux.resolve-all",
        params_converter=JsonTryConverter(ResolveAllParams),
        result_converter=JsonTryConverter(ResolveAllResult),
        error_converter=ERROR_CONVERTER,
    )
    SET_MULTIPLE = MethodDescriptor(
        name="mux.set-multiple",
        params_converter=JsonTryConverter(SetMultipleParams),
        result_converter=JsonTryConverter(SetMultipleResult),
        error_converter=ERROR_CONVERTER,
    )
    CLEAR_AND_REPLACE = MethodDescriptor(
        name="mux.clear-and-replace",
        params_converter=JsonTryConverter(ClearAndReplaceParams),
        result_converter=JsonTryConverter(ClearAndReplaceResult),
        error_converter=ERROR_CONVERTER,
    )
    LOCATION_INFO = MethodDescriptor(
        name="mux.location-info",
        params_converter=JsonTryConverter(LocationInfoParams),
        result_converter=JsonTryConverter(LocationInfoResult),
        error_converter=ERROR_CONVERTER,
    )
