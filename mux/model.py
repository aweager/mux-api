from abc import abstractmethod
from typing import assert_never

from result import Err, Ok, Result

from mux.api import LocationInfoResult

from .errors import MuxApiError


class VariableNamespace:
    @abstractmethod
    async def get_multiple(self, keys: list[str]) -> Result[dict[str, str | None], MuxApiError]:
        """
        Returns the values for the given keys.
        """
        pass

    @abstractmethod
    async def get_all(self) -> Result[dict[str, str], MuxApiError]:
        """
        Returns all values.
        """
        pass

    async def get(self, key: str) -> Result[str | None, MuxApiError]:
        """
        Returns a single value.
        """
        result = await self.get_multiple([key])
        match result:
            case Ok(map):
                return Ok(map[key])
            case Err(error):
                return Err(error)
            case _:
                assert_never(result)

    @abstractmethod
    async def resolve_multiple(self, keys: list[str]) -> Result[dict[str, str | None], MuxApiError]:
        """
        Resolves the values for the given keys.
        """
        pass

    @abstractmethod
    async def resolve_all(self) -> Result[dict[str, str], MuxApiError]:
        """
        Resolves all values.
        """
        pass

    async def resolve(self, key: str) -> Result[str | None, MuxApiError]:
        result = await self.get_multiple([key])
        match result:
            case Ok(map):
                return Ok(map[key])
            case Err(error):
                return Err(error)
            case _:
                assert_never(result)

    @abstractmethod
    async def set_multiple(self, values: dict[str, str | None]) -> Result[None, MuxApiError]:
        """
        Sets multiple values.
        """
        pass

    async def set(self, key: str, value: str | None) -> Result[None, MuxApiError]:
        """
        Sets a single value
        """
        return await self.set_multiple({key: value})

    @abstractmethod
    async def clear_and_replace(self, values: dict[str, str]) -> Result[None, MuxApiError]:
        """
        Clears this namespace of all existing values and sets new ones.
        """
        pass


class Location:
    """
    Represents a location in the mux's graph.
    """

    @abstractmethod
    async def get_info(self) -> Result[LocationInfoResult, MuxApiError]:
        """
        Returns info about this location
        """
        pass

    async def exists(self) -> Result[bool, MuxApiError]:
        """
        Returns True if this location exists.
        """
        return (await self.get_info()).map(lambda x: x.exists)

    async def get_id(self) -> Result[str | None, MuxApiError]:
        """
        Gets a constant, unique ID which can be used to refer to this location.
        """
        return (await self.get_info()).map(lambda x: x.id)

    @abstractmethod
    def namespace(self, name: str) -> VariableNamespace:
        """
        Returns a VariableNamespace object for the specified name.
        """
        pass


class Mux:
    """
    Represents the entire mux instance.
    """

    @abstractmethod
    def location(self, reference: str) -> Result[Location, MuxApiError]:
        """
        Returns a Location object for querying data at the given reference.
        """
        pass
