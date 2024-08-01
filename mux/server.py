import pathlib
import asyncio
from functools import partial
from typing import assert_never

from dataclasses_json import DataClassJsonMixin
from jrpc.connection import wrap_streams
from jrpc.data import (
    JsonRpcError,
    JsonRpcParams,
    ParsedJson,
)
from jrpc.errors import invalid_params, method_not_found

from result import Result, Ok, Err

from mux.api import (
    ClearAndReplaceParams,
    ClearAndReplaceResult,
    GetAllParams,
    GetAllResult,
    GetMultipleParams,
    GetMultipleResult,
    JsonTryLoadMixin,
    LocationInfoParams,
    ResolveAllParams,
    ResolveAllResult,
    ResolveMultipleParams,
    ResolveMultipleResult,
    SetMultipleParams,
    SetMultipleResult,
)
from mux.errors import MuxApiError


from .model import Mux

_methods: dict[str, type[JsonTryLoadMixin]] = {
    "get-multiple": (GetMultipleParams),
    "get-all": (GetAllParams),
    "resolve-multiple": (ResolveMultipleParams),
    "resolve-all": (ResolveAllParams),
    "set-multiple": (SetMultipleParams),
    "clear-and-replace": (ClearAndReplaceParams),
    "location-info": (LocationInfoParams),
}


async def _process_params(
    model: Mux, params
) -> Result[DataClassJsonMixin, MuxApiError]:
    match params:
        case GetMultipleParams():
            return (
                await model.location(params.location)
                .namespace(params.namespace)
                .get_multiple(params.keys)
            ).map(lambda x: GetMultipleResult(x))
        case GetAllParams():
            return (
                await model.location(params.location)
                .namespace(params.namespace)
                .get_all()
            ).map(lambda x: GetAllResult(x))
        case ResolveMultipleParams():
            return (
                await model.location(params.location)
                .namespace(params.namespace)
                .resolve_multiple(params.keys)
            ).map(lambda x: ResolveMultipleResult(x))
        case ResolveAllParams():
            return (
                await model.location(params.location)
                .namespace(params.namespace)
                .resolve_all()
            ).map(lambda x: ResolveAllResult(x))
        case SetMultipleParams():
            return (
                await model.location(params.location)
                .namespace(params.namespace)
                .set_multiple(params.values)
            ).map(lambda _: SetMultipleResult())
        case ClearAndReplaceParams():
            return (
                await model.location(params.location)
                .namespace(params.namespace)
                .clear_and_replace(params.values)
            ).map(lambda _: ClearAndReplaceResult())
        case LocationInfoParams():
            return await model.location(params.ref).get_info()
        case _:
            assert_never(params)


async def _process_rpc(
    model: Mux, method: str, params: JsonRpcParams
) -> Result[ParsedJson, JsonRpcError]:
    if not method in _methods:
        return Err(method_not_found(method))

    params_type = _methods[method]
    match params_type.try_load(params):
        case Ok(loaded_params):
            result = await _process_params(model, loaded_params)
            return result.map(DataClassJsonMixin.to_dict).map_err(
                MuxApiError.to_json_rpc_error
            )
        case Err(schema_error):
            return Err(invalid_params(schema_error))


async def _handle_client(
    model: Mux, reader: asyncio.StreamReader, writer: asyncio.StreamWriter
) -> None:
    await wrap_streams(reader, writer, partial(_process_rpc, model)).process_loop()


async def start(socket_address: pathlib.Path, model: Mux) -> asyncio.Server:
    return await asyncio.start_unix_server(
        partial(_handle_client, model), path=socket_address
    )
