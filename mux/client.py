from asyncio import StreamReader, StreamWriter
from dataclasses import dataclass
from typing import TypeVar, override

from jrpc.client import JsonRpcClient, wrap_streams as jrpc_client_wrap_streams
from jrpc.data import JsonRpcError, ParsedJson
from result import Err, Ok, Result

from .errors import MuxApiError, ResponseSchemaMismatch
from .api import (
    ClearAndReplaceParams,
    GetAllParams,
    GetAllResult,
    GetMultipleParams,
    GetMultipleResult,
    JsonTryLoadMixin,
    LocationInfoParams,
    LocationInfoResult,
    ResolveAllParams,
    ResolveAllResult,
    ResolveMultipleParams,
    ResolveMultipleResult,
    SetMultipleParams,
)

from .model import Location, Mux, VariableNamespace


_TPayload = TypeVar("_TPayload", bound=JsonTryLoadMixin)


def _load_payload(
    schema_class: type[_TPayload],
    rpc_result: Result[ParsedJson, JsonRpcError],
) -> Result[_TPayload, MuxApiError]:
    match rpc_result:
        case Ok(payload):
            match schema_class.try_load(payload):
                case Ok(loaded):
                    return Ok(loaded)
                case Err(schema_error):
                    return Err(
                        MuxApiError.from_data(
                            ResponseSchemaMismatch(schema_class.__name__, schema_error)
                        )
                    )
        case Err(rpc_error):
            return Err(MuxApiError.from_json_rpc_error(rpc_error))


@dataclass
class _ClientNamespace(VariableNamespace):
    _location_reference: str
    _name: str
    _client: JsonRpcClient

    @override
    async def get_multiple(
        self, keys: list[str]
    ) -> Result[dict[str, str | None], MuxApiError]:
        rpc_result = await self._client.request(
            "get-multiple",
            GetMultipleParams(
                location=self._location_reference, namespace=self._name, keys=keys
            ),
        )
        return _load_payload(GetMultipleResult, rpc_result).map(lambda x: x.values)

    @override
    async def get_all(self) -> Result[dict[str, str], MuxApiError]:
        rpc_result = await self._client.request(
            "get-all",
            GetAllParams(
                location=self._location_reference,
                namespace=self._name,
            ),
        )
        return _load_payload(GetAllResult, rpc_result).map(lambda x: x.values)

    @override
    async def resolve_multiple(
        self, keys: list[str]
    ) -> Result[dict[str, str | None], MuxApiError]:
        rpc_result = await self._client.request(
            "resolve-multiple",
            ResolveMultipleParams(
                location=self._location_reference,
                namespace=self._name,
                keys=keys,
            ),
        )
        return _load_payload(ResolveMultipleResult, rpc_result).map(lambda x: x.values)

    @override
    async def resolve_all(self) -> Result[dict[str, str], MuxApiError]:
        rpc_result = await self._client.request(
            "resolve-all",
            ResolveAllParams(
                location=self._location_reference,
                namespace=self._name,
            ),
        )
        return _load_payload(ResolveAllResult, rpc_result).map(lambda x: x.values)

    @override
    async def set_multiple(
        self, values: dict[str, str | None]
    ) -> Result[None, MuxApiError]:
        rpc_result = await self._client.request(
            "set-multiple",
            SetMultipleParams(
                location=self._location_reference,
                namespace=self._name,
                values=values,
            ),
        )
        match rpc_result:
            case Ok():
                return Ok(None)
            case Err(error):
                return Err(MuxApiError.from_json_rpc_error(error))

    @override
    async def clear_and_replace(
        self, values: dict[str, str]
    ) -> Result[None, MuxApiError]:
        rpc_result = await self._client.request(
            "clear-and-replace",
            ClearAndReplaceParams(
                location=self._location_reference,
                namespace=self._name,
                values=values,
            ),
        )
        match rpc_result:
            case Ok():
                return Ok(None)
            case Err(error):
                return Err(MuxApiError.from_json_rpc_error(error))


@dataclass
class _ClientLocation(Location):
    _reference: str
    _client: JsonRpcClient

    @override
    async def get_info(self) -> Result[LocationInfoResult, MuxApiError]:
        rpc_result = await self._client.request(
            "location-info",
            LocationInfoParams(ref=self._reference),
        )
        return _load_payload(LocationInfoResult, rpc_result)

    @override
    def namespace(self, name: str) -> VariableNamespace:
        return _ClientNamespace(self._reference, name, self._client)


@dataclass
class _ClientMux(Mux):
    _client: JsonRpcClient

    @override
    def location(self, reference: str) -> Result[Location, MuxApiError]:
        return Ok(_ClientLocation(reference, self._client))


def wrap_streams(reader: StreamReader, writer: StreamWriter) -> Mux:
    return _ClientMux(jrpc_client_wrap_streams(reader, writer))
