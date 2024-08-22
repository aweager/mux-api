from asyncio import StreamReader, StreamWriter
from dataclasses import dataclass
from typing import TypeVar

from jrpc.client import JsonRpcClient
from jrpc.client import wrap_streams as jrpc_client_wrap_streams
from result import Ok, Result
from typing_extensions import override

from .api import (ClearAndReplace, ClearAndReplaceParams, GetAll, GetAllParams,
                  GetMultiple, GetMultipleParams, JsonTryLoadMixin,
                  LocationInfo, LocationInfoParams, LocationInfoResult,
                  ResolveAll, ResolveAllParams, ResolveMultiple,
                  ResolveMultipleParams, SetMultiple, SetMultipleParams)
from .errors import MuxApiError
from .model import Location, Mux, VariableNamespace

_TPayload = TypeVar("_TPayload", bound=JsonTryLoadMixin)


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
            GetMultiple(
                GetMultipleParams(
                    location=self._location_reference, namespace=self._name, keys=keys
                )
            )
        )
        return rpc_result.map(lambda x: x.values)

    @override
    async def get_all(self) -> Result[dict[str, str], MuxApiError]:
        rpc_result = await self._client.request(
            GetAll(
                GetAllParams(
                    location=self._location_reference,
                    namespace=self._name,
                )
            )
        )
        return rpc_result.map(lambda x: x.values)

    @override
    async def resolve_multiple(
        self, keys: list[str]
    ) -> Result[dict[str, str | None], MuxApiError]:
        rpc_result = await self._client.request(
            ResolveMultiple(
                ResolveMultipleParams(
                    location=self._location_reference,
                    namespace=self._name,
                    keys=keys,
                )
            )
        )
        return rpc_result.map(lambda x: x.values)

    @override
    async def resolve_all(self) -> Result[dict[str, str], MuxApiError]:
        rpc_result = await self._client.request(
            ResolveAll(
                ResolveAllParams(
                    location=self._location_reference,
                    namespace=self._name,
                )
            )
        )
        return rpc_result.map(lambda x: x.values)

    @override
    async def set_multiple(
        self, values: dict[str, str | None]
    ) -> Result[None, MuxApiError]:
        rpc_result = await self._client.request(
            SetMultiple(
                SetMultipleParams(
                    location=self._location_reference,
                    namespace=self._name,
                    values=values,
                )
            )
        )
        return rpc_result.map(lambda _: None)

    @override
    async def clear_and_replace(
        self, values: dict[str, str]
    ) -> Result[None, MuxApiError]:
        rpc_result = await self._client.request(
            ClearAndReplace(
                ClearAndReplaceParams(
                    location=self._location_reference,
                    namespace=self._name,
                    values=values,
                )
            )
        )
        return rpc_result.map(lambda _: None)


@dataclass
class _ClientLocation(Location):
    _reference: str
    _client: JsonRpcClient

    @override
    async def get_info(self) -> Result[LocationInfoResult, MuxApiError]:
        return await self._client.request(
            LocationInfo(
                LocationInfoParams(ref=self._reference),
            )
        )

    @override
    def namespace(self, name: str) -> VariableNamespace:
        return _ClientNamespace(self._reference, name, self._client)


@dataclass
class _ClientMux(Mux):
    _client: JsonRpcClient

    @override
    def location(self, reference: str) -> Result[Location, MuxApiError]:
        return Ok(_ClientLocation(reference, self._client))


def wrap_jrpc_client(client: JsonRpcClient) -> Mux:
    return _ClientMux(client)


def wrap_streams(reader: StreamReader, writer: StreamWriter) -> Mux:
    return _ClientMux(jrpc_client_wrap_streams(reader, writer))
