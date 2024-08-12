from dataclasses import dataclass
from typing import Awaitable, Callable, TypeVar, assert_never

from dataclasses_json import DataClassJsonMixin
from jrpc.data import JsonRpcError, JsonRpcParams, ParsedJson
from jrpc.errors import invalid_params, method_not_found
from result import Err, Ok, Result

from .api import (
    ClearAndReplaceParams,
    ClearAndReplaceResult,
    GetAllParams,
    GetAllResult,
    GetMultipleParams,
    GetMultipleResult,
    JsonTryLoadMixin,
    LocationInfoParams,
    MuxMethodName,
    ResolveAllParams,
    ResolveAllResult,
    ResolveMultipleParams,
    ResolveMultipleResult,
    SetMultipleParams,
    SetMultipleResult,
)
from .errors import MuxApiError
from .model import Location, Mux

_T = TypeVar("_T")

_methods: dict[str, type[JsonTryLoadMixin]] = {
    MuxMethodName.GET_MULTIPLE: GetMultipleParams,
    MuxMethodName.GET_ALL: GetAllParams,
    MuxMethodName.RESOLVE_MULTIPLE: ResolveMultipleParams,
    MuxMethodName.RESOLVE_ALL: ResolveAllParams,
    MuxMethodName.SET_MULTIPLE: SetMultipleParams,
    MuxMethodName.CLEAR_AND_REPLACE: ClearAndReplaceParams,
    MuxMethodName.LOCATION_INFO: LocationInfoParams,
}


@dataclass
class MuxRpcProcessor:
    model: Mux

    async def __call__(
        self, method: str, params: JsonRpcParams
    ) -> Result[ParsedJson, JsonRpcError]:
        if not method in _methods:
            return Err(method_not_found(method))

        params_type = _methods[method]
        match params_type.try_load(params):
            case Ok(loaded_params):
                result = await self._process_params(loaded_params)
                return result.map(DataClassJsonMixin.to_dict).map_err(
                    MuxApiError.to_json_rpc_error
                )
            case Err(schema_error):
                return Err(invalid_params(schema_error))

    async def _use_location(
        self,
        ref: str,
        coro_func: Callable[[Location], Awaitable[Result[_T, MuxApiError]]],
    ) -> Result[_T, MuxApiError]:
        match self.model.location(ref):
            case Ok(location):
                return await coro_func(location)
            case Err() as err:
                return err

    async def _process_params(self, params) -> Result[DataClassJsonMixin, MuxApiError]:
        match params:
            case GetMultipleParams():
                return (
                    await self._use_location(
                        params.location,
                        lambda l: l.namespace(params.namespace).get_multiple(
                            params.keys
                        ),
                    )
                ).map(lambda x: GetMultipleResult(x))
            case GetAllParams():
                return (
                    await self._use_location(
                        params.location,
                        lambda l: l.namespace(params.namespace).get_all(),
                    )
                ).map(lambda x: GetAllResult(x))
            case ResolveMultipleParams():
                return (
                    await self._use_location(
                        params.location,
                        lambda l: l.namespace(params.namespace).resolve_multiple(
                            params.keys
                        ),
                    )
                ).map(lambda x: ResolveMultipleResult(x))
            case ResolveAllParams():
                return (
                    await self._use_location(
                        params.location,
                        lambda l: l.namespace(params.namespace).resolve_all(),
                    )
                ).map(lambda x: ResolveAllResult(x))
            case SetMultipleParams():
                return (
                    await self._use_location(
                        params.location,
                        lambda l: l.namespace(params.namespace).set_multiple(
                            params.values
                        ),
                    )
                ).map(lambda _: SetMultipleResult())
            case ClearAndReplaceParams():
                return (
                    await self._use_location(
                        params.location,
                        lambda l: l.namespace(params.namespace).clear_and_replace(
                            params.values
                        ),
                    )
                ).map(lambda _: ClearAndReplaceResult())
            case LocationInfoParams():
                return await self._use_location(params.ref, lambda l: l.get_info())
            case _:
                assert_never(params)
